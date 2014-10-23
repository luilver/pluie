ObserverSmsJob = Struct.new(:text, :msg) do
  def perform
    numbers_in_msg = msg.receivers
    numbers = []
    observers_numbers = Observer.active.map { |obs| obs.gsm_number.number  }
    observers_numbers.each do |num|
      numbers << num unless numbers_in_msg.include?(num)
    end
    if numbers.any?
      route = Route.publisher_routes.first
      sms = SimpleSms.pluie_sms(text, numbers, route)
      sms.deliver
    end
  end

end
