module Api
  module V1
 #      class SessionsController < Devise::SessionsController
 #      protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/api.knales.v' }
 #
 #  def create
 #    resource=warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
 #    sign_in(resource_name, resource)
 #    render :json => { :info => "Logged in", :user => current_user }, :status => 200
 #  end
 #
 #  def destroy
 #    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
 #    sign_out
 #    render :json => { :info => "Logged out" }, :status => 200
 #  end
 #
 #  def failure
 #    render :json => { :error => "Login Credentials Failed" }, :status => 401
 #  end
 # end
  class SessionsController < Devise::SessionsController
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/api.knales.v' }
  skip_before_filter :authenticate_user!, :only => [:create, :new]
  skip_authorization_check only: [:create, :failure, :show_current_user, :options, :new]
  #after_filter :set_csrf_header, only: [:new, :create]
  respond_to :json

  def new
    self.resource = resource_class.new(sign_up_params)
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end

  def create

    respond_to do |format|
      format.html {
        super
      }
      format.json {

        resource = resource_from_credentials
        #build_resource
        return invalid_login_attempt unless resource

        if resource.valid_password?(params[:password])

           log_write(resource)
           api_setting_x=resource.api_setting
           if api_setting_x.blank?
            api_setting_x=ApiSetting.new({user_id: resource.id})
            api_setting_x.save
           end

           render :json => { user: { email: resource.email, :api_key => api_setting_x.api_key   } }, success: true, status: :created
        else
          invalid_login_attempt
        end
      }
    end
  end

  def destroy
    user_email=""
    token_api_key =""

    if request.headers["HTTP_EMAIL"].present? or request.headers["HTTP_API_KEY"].present? #si una de las dos es true doy por hecho que esta intentando acceder usando autenticacion por headers
      user_email=request.headers["HTTP_EMAIL"].presence
      token_api_key=request.headers["HTTP_API_KEY"].presence
    else
      if params[:authenticate_api].present?
        if params[:authenticate_api][:email].present?
          user_email=params[:authenticate_api][:email].presence
        else
          return (render json: {:message=>'email is missing'}, status: 404)
        end
        if params[:authenticate_api][:api_key].present?
          token_api_key=params[:authenticate_api][:api_key].presence
        else
          return (render json: {:message=>"api key is missing"},status: 404)
        end
      else
        return (render json: {:message=>'email is missing'}, status: 404)
      end
    end

    return (render json: {:message=>'email is missing'}, status: 404) if !user_email
    return (render json: {:message=>'Invalid email'}, status: 422) unless not User.find_by_email(user_email).blank?

        return (render json: {:message=>"api key is missing"},status: 404) if !token_api_key
        if not ApiSetting.find_by_api_key(token_api_key).blank?
           api_setting= ApiSetting.find_by_api_key(token_api_key)

           api_setting.api_key=api_setting.reset_authentication_token!
           #api_setting.save
           #ApiSetting.destroy(api_setting.id)
           log_write(User.find_by_email(user_email))
           render json: { :message => "Session deleted"} , :status => 200, :success => true
        else
           render :json => {:message => 'Invalid api key' }, :status => 422
        end
  end

  protected
  def invalid_login_attempt
    log_write_invalid
    warden.custom_failure!
    data = { email: params[:email] }
    return (render json: {success: false, :message => "email is blank"}, status: 404) if params[:email].blank?
    return (render json: {success: false, :message=>"Invalid email"}, status: 422) if User.find_by_email(params[:email]).blank?
    return ( render json: { success: false, message: 'password missing'}, status: 404) if params[:password].blank?
    render json: { success: false, message: 'Invalid password' }, status: 422
  end

  def resource_from_credentials
    data = { email: params[:email] }
    if res = resource_class.find_for_database_authentication(data)
      if res.valid_password?(params[:password])
        res
      end
    end
  end

  def log_write (resource)
    HistoricLog.create(:controller_name=>params[:controller],:action_name=>params[:action],:parameter_req=>nil,:user_id=>resource.id,:mask_user_active=>nil,:parameters_not_comun=>nil,:full_path=>request.fullpath)
  end

  def log_write_invalid
    list_parameters=[]
    params.each  do |key, value|
      list_parameters << key.to_s+':'+value.to_s if key!='controller' and key!=:action.to_s and key!=:id.to_s
    end
    HistoricLog.create(:controller_name=>params[:controller],:action_name=>params[:action],:parameter_req=>nil,:user_id=>0,:mask_user_active=>nil,:parameters_not_comun=>list_parameters.join(','),:full_path=>request.fullpath)
  end

  # def set_csrf_header
  #   response.headers['X-CSRF-Token'] = form_authenticity_token
  # end
    end
  end
end
