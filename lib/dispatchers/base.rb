module DeliveryMethods

  class Base

    def initialize(user)
      @current_user = user
    end

    begin

      def send_message(single_msg)
        numbers, text = get_numbers_and_text(single_msg)
        unit_price = @current_user.gateway.price
        msg_sended = false
        cost = 0

        numbers.each do |num|
          if @current_user.balance >= unit_price
            success = send_single_message(num, text)
            msg_sended ||= success
            cost += unit_price if success
          else
            log_error("Failed sending msg to: #{num}. Not enough credit")
          end
        end

        if msg_sended
          @current_user.balance -= cost
          @current_user.save
        end

      end

      def send_bulk(bulk_msg)
        send_message(bulk_msg)
        #Por ahora los mensajes en bulk se envian de la misma manera que los
        #mensajes de multiples destinatarios... la idea es que esto se resuelva
        #con un servicio de smpp
      end

    rescue Exception => e
      log_error(e.message)
    end

    protected
      def log_error(error_msg)
        Rails.logger.error "<<<<<<<<<<<<#{error_msg}>>>>>>>>>>>>"
      end

      def log_info(info)
        Rails.logger.info "<<<<<<<<<<<<#{info}>>>>>>>>>>>>"
      end

    private
      def get_numbers_and_text(msg)
        #para usarlo en los mensajes en bulk tambien
        numbers = msg.gsm_numbers.map { |n| n.number  }
        text =  msg.message
        return numbers, text
      end

  end

end
