module DeliveryMethods

  class Base

    begin

      def send_message(single_msg)
        numbers = single_msg.gsm_numbers.map { |n| n.number  }
        text = single_msg.message
        unit_price = current_user.gateway.price
        msg_sended = false
        cost = 0

        numbers.each do |num|
          if current_user.balance >= unit_price
            success = send_single_message(num, text)
            msg_sended ||= success
            cost += unit_price if success
          else
            log_error("Failed sending msg to: #{num}. Not enough credit")
          end
        end

        if msg_sended
          current_user.balance -= cost
          current_user.save
        end

      end

      def send_bulk(bulk_msg)
        numbers = bulk_msg.gsm_numbers.map {|n| n.number}
        text = bulk_msg.message
        send_bulk_messages(numbers, text)
      end

    rescue Exception => e
      log_error(e.message)
    end

    protected
      def log_error(error_msg)
        Rails.logger.error "<<<<<<<<<<<<#{error_msg}>>>>>>>>>>>>"
      end

  end

end
