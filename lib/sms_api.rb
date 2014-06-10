module SmsApi
    require 'clockwork'
    require 'nexmo'

    module ClassMethods

    end

    module InstanceMethods

      def get_sms_dispatcher(&on_response)
          ClockWorks.new()
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    class Nexmo
      def initialize(&on_response)
        @nexmo = Nexmo::Client.new(key = ENV['NEXMO_API_KEY'], secret = ENV['NEXMO_API_SECRET'],  on_response)
      end

      def send_single_message(to, text)
        response = @nexmo.send_message({:to => to, :from => '', :text => text})
      end

      def send_multiple_messages(numbers, text)

      end

    end

    class  ResponseProvider
      def initialize(&on_response)
        @response_block = on_response
      end

      protected
        def decode_response(api_response)
          @response_block ? @response_block.call(api_response) : api_response
        end

    end
#add threading
    class ClockWorks < ResponseProvider
      def initialize(args, &on_response)
        super(on_response)
        @api = Clockwork::API.new(ENV['TEST_CLOCKWORKS_KEY'])
      end

      def send_single_message(to, text)
        #to The phone number to send the SMS to in international number format (without a leading + or international dialling prefix such as 00, e.g. 441234567890).
        message = @api.messages.build(:to => to, :content => text)
        response = message.deliver

        #TODO ver si se implementa un objeto response custom, que agrupe las funcionalidades de cada provider
        decode_response(response)

      end

      def send_multiple_messages(numbers, text)

        numbers.each do |n|
          api.messages.build({:to => n, :content => text})
        end

        responses = api.deliver_messages
        responses.each do |response|
          decode_response response
        end
      end

    end
end
