class SingleDeliverer

  def self.deliver(message)
    bill = Bill.create(number_of_sms: 1, message_id: message.pluie_message_id, user: message.user)
    text = message.message
    route = message.route
    type = message.pluie_type
    sms = SimpleSms.custom(text, message.receivers, route, bill.id, type, message.id)
    sms.deliver
  end
end
