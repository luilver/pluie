module DeliveryMethods

  class Base

    def send_message(single_msg)
      if single_msg.gsm_numbers.count == 1
        send_single_message(single_msg.gsm_numbers.first.number, single_msg.message)
      else
        send_multiple_messages(single_msg.gsm_numbers.map { |n| n.number  }, single_msg.message)
      end
    end

    def send_bulk(bulk_msg)
      numbers = bulk_msg.gsm_numbers.map {|n| n.number}
      text = bulk_msg.message
      send_bulk_messages(numbers, text)
    end

  end

end
