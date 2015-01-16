ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "paperclip/matchers"
require "webmock/minitest"
require 'mocha/mini_test'
require "minitest/rails/capybara"
require 'shoulda/context'

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

  def self.random
    @random ||= Random.new
  end

  def random
    ActiveSupport::TestCase.random
  end

  def generate_collection(size, &block)
    items = []
    size.times {|i| items << (yield block)}
    items
  end

  def self.cubacel_random_number
    random.rand(5350000000..5359999999).to_s
  end

  def cubacel_random_number
    self.class.cubacel_random_number
  end

  def cubacel_numbers(amount)
    generate_collection(amount) {cubacel_random_number}
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

  def stub_request_for_async_test
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
  end

  def user_accounting_info(user)
    "balance: #{user.balance} credit: #{user.credit} debit: #{user.debit}"
  end

  def stub_soap_response(operation, data = {code: 1, message: "message"})
    resp_key = "#{operation}_response".to_sym
    result_key = "#{operation}_result".to_sym
    stub(body: {resp_key => {result_key => data}})
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

  def assert_message_is_charged(msg, deliverer)
    cost = msg.message_cost
    id = msg.user.id
    assert_differences [['User.find(id).balance', -cost], ['User.find(id).debits.count', 1], ['User.find(id).bills.count', 1]] do
      cmd = DeliverMessage.new(deliverer)
      cmd.deliver(msg)
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
