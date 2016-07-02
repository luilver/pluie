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
    if !current_user.nil? and  controller_name!=HomeController.name.demodulize.sub(/Controller$/, '').underscore and !(params[:controller]=="registrations") and  (params[:controller]!="confirmation_number")
      if current_user.role?('mask_user')
        User.all.each do |u|
          if u.nested_reseller.to_i==current_user.id
            @current_user=u
            break
          end
        end
      end
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => I18n.t('cancan.access_denied').html_safe
  end
end
