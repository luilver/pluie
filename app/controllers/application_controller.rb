class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate_user!
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  before_filter do
    @mask_u=0
    if !current_user.nil? and  controller_name!=HomeController.name.demodulize.sub(/Controller$/, '').underscore and !(params[:controller]=="registrations")
      if current_user.role?('mask_user')
        User.all.each do |u|
          if u.nested_reseller.to_i==current_user.id
            @current_user=u
            @mask_u=current_user.nil? ? 0 : current_user.id
            break
          end
        end
      end
    end
  end

  before_action do
    if params[:controller]=='devise/sessions' and (params[:action]=='destroy' or params[:action]=='create') and !@current_user.nil?
      HistoricLog.create(:controller_name=>params[:controller],:action_name=>params[:action],:parameter_req=>nil,:user_id=>@current_user.id,:mask_user_active=>nil,:parameters_not_comun=>nil,:full_path=>request.fullpath)
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    list_parameters=[]
    parameters=params[:id] if !params[:id].blank?
    params.each  do |key, value|
      list_parameters << key.to_s+':'+value.to_s if key!='controller' and key!=:action.to_s and key!=:id.to_s
    end
    HistoricLog.create(:controller_name=>params[:controller],:action_name=>params[:action],:parameter_req=>parameters,:user_id=>@current_user.id,:mask_user_active=>@mask_u,:parameters_not_comun=>list_parameters.join(','),:full_path=>request.fullpath)

    redirect_to main_app.root_url, :alert => I18n.t('cancan.access_denied').html_safe
  end
end
