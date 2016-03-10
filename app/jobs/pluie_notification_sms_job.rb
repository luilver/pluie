PluieNotificationSmsJob = Struct.new(:text, :number) do
  def perform
    route = Route.notifications_route
    bill = Bill.create(number_of_sms: 1, user: route.users.first)
    sms = SimpleSms.pluie_sms(text, number, route, bill.id)
    sms.deliver
  end
end
