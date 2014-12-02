ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "paperclip/matchers"
require "webmock/minitest"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

class ActiveSupport::TestCase
    ActiveRecord::Migration.check_pending!
    extend Paperclip::Shoulda::Matchers
    include ActionDispatch::TestProcess
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

  def cubacel_numbers(amount)
    l = []
    amount.times {|t| l << cubacel_random_number }
    l
  end

  def attach_file_from_fixture(list, filename=nil)
    filename ||= "#{list.name}.txt"
    list.update(file: File.new(File.join(Rails.root, "test/fixtures", filename)))
    list
  end

  def setup_list(fixture_key, attach_nums=true)
    list = attach_file_from_fixture(lists(fixture_key))
    list.attach_numbers if attach_nums
    list
  end

  def clean_paperclip_file_directory
    dir = Paperclip::Attachment.default_options[:path].sub(":class/:id_partition/:style.:extension","")
    FileUtils.rm_rf(Dir[dir])
  end

  def gateway_url_for_tests
    ActionSmser::DeliveryMethods::AsyncTest.full_url
  end

  def simple_response(request)
    ActionSmser::DeliveryMethods::AsyncTest.generate_response_from_body(request.body)
  end

  def add_credit(user, amount)
    credit = Credit.create(description: "test credit", balance: amount, user: user)
  end

  def fix_users_credit
    #If fixtures are used to load the data, the callbacks are not runned
    #therefor the credit field in user must be exec manually
    Credit.all.each {|c| c.user.credit += c.balance; c.save_owner}
  end

  def run_observers_save_callback
    Observer.all.each {|obs| obs.save}
  end

  def user_accounting_info(user)
    "balance: #{user.balance} credit: #{user.credit} debit: #{user.debit}"
  end

  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }
    yield
    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
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
