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
        token_api_key=request.headers["HTTP_API_KEY"]
        return (render json: {:message=>'email is missing'}, status: 404) if request.headers["HTTP_EMAIL"].blank?
        return (render json: {:message=>'Invalid email'}, status: 422) unless not User.find_by_email(request.headers["HTTP_EMAIL"]).blank?

        return (render json: {:message=>"api key is missing"},status: 404) if request.headers["HTTP_API_KEY"].blank?
        if not ApiSetting.find_by_api_key(token_api_key).blank?
           api_setting= ApiSetting.find_by_api_key(token_api_key)

           api_setting.api_key=api_setting.reset_authentication_token!
           #api_setting.save
           #ApiSetting.destroy(api_setting.id)
           render json: { :message => "Session deleted"} , :status => 200, :success => true
        else
           render :json => {:message => 'Invalid api key' }, :status => 422
        end
  end

  protected
  def invalid_login_attempt
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

  # def set_csrf_header
  #   response.headers['X-CSRF-Token'] = form_authenticity_token
  # end
    end
  end
end
