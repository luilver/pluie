require 'factory'

module DeliveryMethods

  class Base

    include Factory

    def initialize(user)
      @current_user = user
    end

    begin

      def send_message(single_msg)
        numbers, text = get_numbers_and_text(single_msg)
        unit_price = @current_user.gateway.price

        any_success = process_messages(numbers, text, unit_price)

        @current_user.save if any_success

      end

      def send_bulk(bulk_msg)
        send_message(bulk_msg)
        #Por ahora los mensajes en bulk se envian de la misma manera que los
        #mensajes de multiples destinatarios... la idea es que esto se resuelva
        #con un servicio de smpp
      end

      #En las api http usualmente se envian, uno por uno los sms
      #en el caso de smpp, se debe implementar este metodo nuevamente
      #para crear la conexion una sola vez y encolar todos los sms
      def send_sms(sms_list)
        sms_list.each do |sms|
          send_single_sms(sms)
        end
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

      def process_messages(numbers, text, unit_price)

        msg_sent = false
        numbers.each do |num|
          if @current_user.balance >= unit_price
            success = send_single_message(num, text)
            msg_sent ||= success
            @current_user.balance -= unit_price if success
          else
            log_error("Failed sending msg to: #{num}. Not enough credit")
          end
        end

        return msg_sent
      end

      def cubacel_random_number
        result = "535"
        rand = Random.new
        7.times{ result << rand.rand(9).to_s}
        result
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
