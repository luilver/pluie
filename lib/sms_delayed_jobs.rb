module SmsApi

    class SingleMessageJob

      def initialize(dispatcher, single_msg)
        @dispatcher = dispatcher
        @single_msg = single_msg
      end

      def perform
          if @single_msg.gsm_numbers.count == 1
            @dispatcher.send_single_message(@single_msg.gsm_numbers.first.number, single_msg.message)
          else
            @dispatcher.send_multiple_messages(@single_msg.gsm_numbers.map { |n| n.number  }, single_msg.message)
          end
        end
    end
end
