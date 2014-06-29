module DeliveryMethods

  class ClockWorksHttp
      def initialize(&on_response)
        @api = Clockwork::API.new(ENV['TEST_CLOCKWORKS_KEY'])
      end

      def send_single_message(to, text)
        #to The phone number to send the SMS to in international number format (without a leading + or international dialling prefix such as 00, e.g. 441234567890).
        message = @api.messages.build(:to => to, :content => text)
        response = message.deliver
      end

      def send_multiple_messages(numbers, text)

        numbers.each do |n|
          api.messages.build({:to => n, :content => text})
        end

        responses = api.deliver_messages
        end
      end

    end

end
