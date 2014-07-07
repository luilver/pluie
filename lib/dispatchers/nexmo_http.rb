require 'dispatchers/base'

module DeliveryMethods

    class NexmoHttp < DeliveryMethods::Base

      def initialize
        super
        @nexmo = Nexmo::Client.new(key = ENV['NEXMO_API_KEY'], secret = ENV['NEXMO_API_SECRET'])
      end

      def send_single_message(to, text)
        response = @nexmo.send_message({:to => to, :text => text})
      end

      def send_multiple_messages(numbers, text)
        numbers.each do |number|
          @nexmo.send_message({:to => number, :text => text})
        end
      end

      def get_balance
        response = @nexmo.get_balance
        response.ok? ? response.object['value']:0
      end

  end
end
