#infobip -> oneapi
INFOBIP_KEY = ENV['INFOBIP_KEY']
INFOBIP_PASS = ENV['INFOBIP_PASS']

#nexmo -> enabled for smpp use
NEXMO_KEY = ENV['NEXMO_API_KEY']
NEXMO_PASS = ENV['NEXMO_API_SECRET']

PLUIE_HOST = Pluie::Application.config.default_url_options[:host]

if Rails.env.development? || Rails.env.production?
  require 'action_smser_delivery_methods' #load the DeliveryMethods implemented in this app
  require 'action_smser_utils' #to modify the ActionSmser::DeliveryReport model

  ActionSmser.delivery_options[:delivery_method] = :async_infobip
  ActionSmser.delivery_options[:save_delivery_reports] = true
  ActionSmser.delivery_options[:gateway_commit]['infobip'] = ActionSmser::DeliveryMethods::AsyncInfobip
  ActionSmser.delivery_options[:infobip] = { username: INFOBIP_KEY, password: INFOBIP_PASS, numbers_in_request: 50, parallel_requests: 5 }
  ActionSmser.delivery_options[:admin_access] = ActionSmserUtils
  ActionSmser.delivery_options[:numbers_from_bulk] = 0.1
  ActionSmser.delivery_options[:min_numbers_in_sms] = 100
end
