require 'action_smser_delivery_methods' #load the DeliveryMethods implemented in this app
require 'action_smser_utils' #to modify the ActionSmser::DeliveryReport model

#infobip -> oneapi
INFOBIP_KEY = ENV['INFOBIP_KEY']
INFOBIP_PASS = ENV['INFOBIP_PASS']

#nexmo -> enabled for smpp use
NEXMO_KEY = ENV['NEXMO_API_KEY']
NEXMO_PASS = ENV['NEXMO_API_SECRET']

ROUTESMS_KEY = ENV['ROUTESMS_KEY']
ROUTESMS_PASS = ENV['ROUTESMS_PASS']

PLUIE_HOST = Pluie::Application.config.default_url_options[:host]

def gateway_defined?(key)
  ActionSmser.delivery_options.has_key?(key)
end

def deliveries_test_array
  ActionSmser::DeliveryMethods::AsyncTest.deliveries
end

if Rails.env.test?
  require 'action_smser/delivery_methods/async_test'

  ActionSmser.delivery_options[:delivery_method] = :async_test
  ActionSmser.delivery_options[:numbers_from_bulk] = 0.1
  ActionSmser.delivery_options[:min_numbers_in_sms] = 5
  ActionSmser.delivery_options[:test] = {username: "user", password: "password", numbers_in_request: 5, parallel_requests: 5 }
end

if Rails.env.development? || Rails.env.staging? || Rails.env.production?
  ActionSmser.delivery_options[:delivery_method] = :async_infobip
  ActionSmser.delivery_options[:save_delivery_reports] = true
  ActionSmser.delivery_options[:admin_access] = ActionSmserUtils
  ActionSmser.delivery_options[:numbers_from_bulk] = 0.1
  ActionSmser.delivery_options[:min_numbers_in_sms] = 100

  ActionSmser.delivery_options[:gateway_commit]['infobip'] = ActionSmser::DeliveryMethods::AsyncInfobip
  ActionSmser.delivery_options[:infobip] = { username: INFOBIP_KEY, password: INFOBIP_PASS, numbers_in_request: 50, parallel_requests: 5 }

  ActionSmser.delivery_options[:gateway_commit]['routesms'] = ActionSmser::DeliveryMethods::AsyncRoutesms
  ActionSmser.delivery_options[:routesms] = { username: ROUTESMS_KEY, password: ROUTESMS_PASS, numbers_in_request: 5, parallel_requests: 10 }
  ActionSmser.delivery_options[:routesms1] = { username: ENV['ROUTESMS1_KEY'], password: ENV['ROUTESMS1_PASS'], numbers_in_request: 5, parallel_requests: 10 }

  ActionSmser.delivery_options[:gateway_commit]['nexmo'] = ActionSmser::DeliveryMethods::AsyncNexmo
  ActionSmser.delivery_options[:nexmo] = { username: NEXMO_KEY, password: NEXMO_PASS, numbers_in_request: 1, parallel_requests: 25 }
end
