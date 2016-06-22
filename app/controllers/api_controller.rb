class ApiController < ActionController::Base
  before_filter :authenticate_api!
  #load_and_authorize_resource
  prepend_before_filter :ensure_params_exist
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  rescue_from CanCan::AccessDenied do |exception|
    render :json => { :sucess => false,
                      :message => exception.message }, :status => 403
  end

  def authenticate_api!
    user_email=""
    user_token_api_key =""

    if request.headers["HTTP_EMAIL"].present? or request.headers["HTTP_API_KEY"].present? #si una de las dos es true doy por hecho que esta intentando acceder usando autenticacion por headers
      user_email=request.headers["HTTP_EMAIL"].presence
      user_token_api_key=request.headers["HTTP_API_KEY"].presence
    else
      user_email=params[:authenticate_api][:email].presence
      user_token_api_key=params[:authenticate_api][:api_key].presence
    end

    user = User.find_by_email(user_email)
    #api = ApiSetting.find_by_api_key(user.ap)

    if user
      if Devise.secure_compare(user.api_key, user_token_api_key)
        User.current=user
        return
      else
       return invalid_api_key
      end
    else
      return not_user
    end
  end

  before_filter do
    @user_mask_api=false
    if User.current.role?('mask_user') and !params[:mask_in_user].blank?
      if controller_name==BulkMessage.name.demodulize.sub(/Controller$/, '').underscore.pluralize
        User.current=User.find_by_email(params[:mask_in_user]) if !User.where(:email=>params[:mask_in_user]).blank?
        return render :json => {:message=>"invalid email: #{params[:mask_in_user]}"},:status=>422 if User.where(:email=>params[:mask_in_user]).blank?
        @user_mask_api=true
        return
      end
    end
  end

  protected

    def not_user
    render json: {success: false, message: "Invalid email"}, status: 400
    end

    def ensure_params_exist
       if request.headers["HTTP_API_KEY"].blank?
          if params[:authenticate_api].present?
            if !params[:authenticate_api][:api_key].present?
              return render :json => { :success => false,
                                       :message => "missing api key" }, :status => 400
            end
          else
            return render :json => { :success => false,
                                     :message => "missing api key" }, :status => 400
          end
       end

       if request.headers["HTTP_EMAIL"].blank?
         if params[:authenticate_api].present?
           if !params[:authenticate_api][:email].present?
             return render :json => { :success => false, :message => "missing email" }, :status => 400
           end
         else
           return render :json => { :success => false,
                                    :message => "missing email" }, :status => 400
         end
       end

       return
    end

    def invalid_api_key
      render :json => { :success => false,
                     :message => 'invalid api key' }, :status => 401
    end

    def invalid_api_secret
      render :json => { :success => false,
                     :message => 'invalid api secret' }, :status => 401
    end
end
