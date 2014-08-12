require_relative 'base'

module DeliveryMethods

    class NexmoHttp < DeliveryMethods::Base

      register_subclass "nexmo_http"

      def initialize(user)
        super
        @nexmo = Nexmo::Client.new(key = NEXMO_KEY, secret = NEXMO_PASS)
      end

      def send_single_message(to, text)
        begin
          response = @nexmo.send_message({:to => to, :text => text})
          log_info("Sending message to: #{to} #{response.ok? ? "sucessful" : "failed"}")
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
