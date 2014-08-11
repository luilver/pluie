if Rails.env.development? || Rails.env.production?
  require 'action_smser_delivery_methods' #load the DeliveryMethods implemented in this app

  ActionSmser.delivery_options[:delivery_method] = :async_infobip
  #ActionSmser.delivery_options[:delivery_method] = :nexmo
  #ActionSmser.delivery_options[:nexmo] = {:username => NEXMO_KEY, :password => NEXMO_PASS }
  #ActionSmser.delivery_options[:delayed_job] = { :delivery_method => :nexmo, :priority => 0 }
  # ActionSmser.delivery_options[:save_delivery_reports] = true
end
