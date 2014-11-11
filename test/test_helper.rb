ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

#to set locale in url build during tests
class ActionController::TestCase
  def process_with_default_locale(action, http_method = 'GET', parameters = nil, session = nil, flash = nil)
    parameters = {:locale=> I18n.locale }.merge(parameters||{})
    process_without_default_locale(action, http_method,  parameters, session, flash)
  end
  alias_method_chain :process, :default_locale
end
