module DeliveryMethods

  class Base

    def send_message(single_msg)
      numbers = single_msg.gsm_numbers.map { |n| n.number  }
      text = single_msg.message

      numbers.each do |num|
        if current_user.balance >= current_user.gateway.price

        end
        success = send_single_message(num, text)
      end

    end

    def send_bulk(bulk_msg)
      numbers = bulk_msg.gsm_numbers.map {|n| n.number}
      text = bulk_msg.message
      send_bulk_messages(numbers, text)
    end

    protected
      def log_error(error_msg)
        Rails.logger.error "<<<<<<<<<<<<#{error_msg}>>>>>>>>>>>>"
      end

  end

end
