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
    api = ApiSetting.find_by_api_key(params[:api_key])

    return invalid_api_key unless api
    return invalid_api_secret unless api.valid_secret?(params[:api_secret])
    User.current = api.user
  end

  protected
    def ensure_params_exist
       return unless params[:api_key].blank?
       render :json => { :success => false,
                         :message => "missing api key" }, :status => 400
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
