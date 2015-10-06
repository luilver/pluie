class ApiController < ActionController::Base
  before_filter :authenticate_api!
  load_and_authorize_resource
  prepend_before_filter :ensure_params_exist
  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    render :json => { :sucess => false,
                      :message => exception.message }, :status => 403
  end

  def authenticate_api!
    user_email=request.headers["HTTP_EMAIL"].presence
    user_token_api_key=request.headers["HTTP_API_KEY"].presence

    user = User.find_by_email(user_email)
    #api = ApiSetting.find_by_api_key(user.ap)

    if user
      if Devise.secure_compare(user.api_key, user_token_api_key)
        User.current=user
      else
       return invalid_api_key
      end
    else
      return not_user
    end
  end

  protected

    def not_user
    render json: {success: false, message: "Not user with this gmail"}, status: 400
    end

    def ensure_params_exist

       if request.headers["HTTP_API_KEY"].blank?
       return render :json => { :success => false,
                         :message => "missing api key" }, :status => 400
       end
       if request.headers["HTTP_EMAIL"].blank?
         return render :json => { :success => false,
                           :message => "missing email" }, :status => 400
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
