if Rails.env.development? || Rails.env.production?
  require 'action_smser_delivery_methods' #load the DeliveryMethods implemented in this app
  require 'action_smser_utils' #to modify the ActionSmser::DeliveryReport model

  ActionSmser.delivery_options[:delivery_method] = :async_infobip
  ActionSmser.delivery_options[:save_delivery_reports] = true
  ActionSmser.delivery_options[:gateway_commit]['infobip'] = ActionSmser::DeliveryMethods::AsyncInfobip
end