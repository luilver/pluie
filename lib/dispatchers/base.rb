module DeliveryMethods

  class Base

    def send_message(single_msg)
      if single_msg.gsm_numbers.count == 1
        send_single_message(single_msg.gsm_numbers.first.number, single_msg.message)
      else
        send_multiple_messages(single_msg.gsm_numbers.map { |n| n.number  }, single_msg.message)
      end
    end

  end

end
