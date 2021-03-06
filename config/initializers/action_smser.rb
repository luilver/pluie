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

CARDBOARDFISH_KEY = ENV['CARDBOARDFISH_KEY']
CARDBOARDFISH_PASS = ENV['CARDBOARDFISH_PASS']

FORTYTWO_KEY =ENV['FORTYTWO_KEY']
FORTYTWO_PASS = ENV['FORTYTWO_PASS']


TWILIO_KEY = ENV['TWILIO_KEY']
TWILIO_TOKEN = ENV['TWILIO_TOKEN']

TM4B_KEY = ENV['TM4B_KEY']
TM4B_PASS = ENV['TM4B_PASS']

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
  ActionSmser.delivery_options[:infobip] = { username: INFOBIP_KEY, password: INFOBIP_PASS, numbers_in_request: 5, parallel_requests: 5 }

  ActionSmser.delivery_options[:gateway_commit]['routesms'] = ActionSmser::DeliveryMethods::AsyncRoutesms
  ActionSmser.delivery_options[:routesms] = { username: ROUTESMS_KEY, password: ROUTESMS_PASS, numbers_in_request: 5, parallel_requests: 10 }
  ActionSmser.delivery_options[:routesms1] = { username: ENV['ROUTESMS1_KEY'], password: ENV['ROUTESMS1_PASS'], numbers_in_request: ENV['ROUTESMS1_NUMBERS_IN_REQUEST'].to_i, parallel_requests: ENV['ROUTESMS1_PARALLEL_REQUESTS'].to_i }

  ActionSmser.delivery_options[:gateway_commit]['nexmo'] = ActionSmser::DeliveryMethods::AsyncNexmo
  ActionSmser.delivery_options[:nexmo] = { username: NEXMO_KEY, password: NEXMO_PASS, numbers_in_request: 1, parallel_requests: 25 }


  ActionSmser.delivery_options[:gateway_commit]['cardboardfish'] = ActionSmser::DeliveryMethods::AsyncCardboardfish
  ActionSmser.delivery_options[:cardboardfish] = { username: CARDBOARDFISH_KEY, password: CARDBOARDFISH_PASS, numbers_in_request: 5, parallel_requests: 5 }


  ActionSmser.delivery_options[:gateway_commit]['twilio'] = ActionSmser::DeliveryMethods::AsyncTwilio
  ActionSmser.delivery_options[:twilio] = { username: TWILIO_KEY, password: TWILIO_TOKEN, numbers_in_request: 5, parallel_requests: 5 }


  ActionSmser.delivery_options[:gateway_commit]['fortytwo'] = ActionSmser::DeliveryMethods::AsyncFortytwo
  ActionSmser.delivery_options[:fortytwo] = { username: FORTYTWO_KEY, password: FORTYTWO_PASS, numbers_in_request: 5, parallel_requests: 5 }

  ActionSmser.delivery_options[:gateway_commit]['tm4b'] = ActionSmser::DeliveryMethods::AsyncTm4b
  ActionSmser.delivery_options[:tm4b] = { username: TM4B_KEY, password: TM4B_PASS, numbers_in_request: 5, parallel_requests: 5 }

end
