if Rails.env.development? || Rails.env.production?

  ActionSmser.delivery_options[:delivery_method] = :delayed_job
  ActionSmser.delivery_options[:smstrade] = {
      :username => 'username', :password => 'password' }
  ActionSmser.delivery_options[:delayed_job] = { :delivery_method => :smstrade, :priority => 0 }
  # ActionSmser.delivery_options[:save_delivery_reports] = true
end
