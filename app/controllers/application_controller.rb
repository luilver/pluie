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

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => I18n.t('cancan.access_denied').html_safe
  end

  before_action :set_locale

  def set_locale
    l = params[:locale] if I18n.available_locales.map(&:to_s).include?(params[:locale])
    I18n.locale = l || I18n.default_locale
  end

  def default_url_options(options = {})
    {locale: I18n.locale}
  end
end
