module SmsApi
    require 'clockwork'

    module ClassMethods

    end

    module InstanceMethods

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    class ClockWorks
      def initialize(args)
        @api = Clockwork::API.new(ENV['TEST_CLOCKWORKS_KEY'])
      end

      def send_single_message(to, text)
        #to The phone number to send the SMS to in international number format (without a leading + or international dialling prefix such as 00, e.g. 441234567890).
        @api.messages.build(:to => to, :content => text)

        response = message.deliver
      end

      def send_multiple_messages(numbers, text)

        numbers.each do |n|
          api.messages.build({:to => n, :content => text})
        end
      end

    end
end
