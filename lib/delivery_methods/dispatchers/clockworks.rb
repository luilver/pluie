require_relative 'base'
require 'clockwork'

module DeliveryMethods

    class Clockworks < DeliveryMethods::Base

      register_subclass "clockwork"

      def initialize(user)
        super
        @api_key =  ENV['CLOCKWORKS_API_KEY']
      end

      def send_single_message(to, text)
        begin
          api = Clockwork::API.new(@api_key)
          msg = api.messages.build
          msg.to = to
          msg.content = text
          response = msg.deliver

          log_info("Sending message to: #{to} #{response.sucess ? "sucessful": "failed " + response.error_description}")
          return response.success
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
