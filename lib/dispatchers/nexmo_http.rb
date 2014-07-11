require 'dispatchers/base'

module DeliveryMethods

    class NexmoHttp < DeliveryMethods::Base

      def initialize(user)
        super
        @nexmo = Nexmo::Client.new(key = ENV['NEXMO_API_KEY'], secret = ENV['NEXMO_API_SECRET'])
      end

      def send_single_message(to, text)
        begin
          response = @nexmo.send_message({:to => to, :text => text})
          response.ok?
        rescue Exception => e
          log_error("Failed sending msg to: #{to}. #{e.message}")
          return false
        end
      end

      def get_balance
        response = @nexmo.get_balance
        response.ok? ? response.object['value']:0
      end

  end
end
