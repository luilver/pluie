#infobip -> oneapi
INFOBIP_KEY = ENV['INFOBIP_KEY']
INFOBIP_PASS = ENV['INFOBIP_PASS']

#nexmo -> enabled for smpp use
NEXMO_KEY = ENV['NEXMO_API_KEY']
NEXMO_PASS = ENV['NEXMO_API_SECRET']

PLUIE_HOST = ENV['PLUIE_HOST'].chomp('/')#to build the callback url for gateway commit

if Rails.env.development? || Rails.env.production?
  require 'action_smser_delivery_methods' #load the DeliveryMethods implemented in this app
  require 'action_smser_utils' #to modify the ActionSmser::DeliveryReport model

  ActionSmser.delivery_options[:delivery_method] = :async_infobip
  ActionSmser.delivery_options[:save_delivery_reports] = true
  ActionSmser.delivery_options[:gateway_commit]['infobip'] = ActionSmser::DeliveryMethods::AsyncInfobip
  ActionSmser.delivery_options[:infobip] = {unit_price: 0.01, username: INFOBIP_KEY, password: INFOBIP_PASS}
  ActionSmser.delivery_options[:admin_access] = ActionSmserUtils
end
