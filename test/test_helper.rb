ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "paperclip/matchers"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
    ActiveRecord::Migration.check_pending!
    extend Paperclip::Shoulda::Matchers
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def cubacel_random_number
    result = "535"
    rand = Random.new
    7.times{ result << rand.rand(9).to_s}
    result
  end
end

#to set locale in url build during tests
class ActionController::TestCase
  include Devise::TestHelpers

  def process_with_default_locale(action, http_method = 'GET', parameters = nil, session = nil, flash = nil)
    parameters = {:locale=> I18n.locale }.merge(parameters||{})
    process_without_default_locale(action, http_method,  parameters, session, flash)
  end
  alias_method_chain :process, :default_locale
end
