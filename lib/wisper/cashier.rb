module PluieWisper
  class Cashier

    def finish_sending(sms, succesfull_numbers)
      bill = sms.pluie_message_id && Bill.find_by_message_id(sms.pluie_message_id)
      if bill
        bill.update_and_charge_if_ended(succesfull_numbers, sms.route_id, sms.body_parts)
      end
    end
  end
end
