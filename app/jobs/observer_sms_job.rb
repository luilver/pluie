ObserverSmsJob = Struct.new(:text, :numbers_in_msg) do
  def perform
    numbers = []
    observers_numbers = Observer.active_numbers
    observers_numbers.each do |num|
      numbers << num unless numbers_in_msg.include?(num)
    end
    if numbers.any?
      route = Route.notifications_route
      bill = Bill.create(number_of_sms: 1, user: route.users.first)
      sms = SimpleSms.pluie_sms(text, numbers, route, bill.id)
      sms.deliver
    end
  end
end
