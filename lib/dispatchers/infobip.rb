require 'dispatchers/base'
require 'oneapi-ruby'

module DeliveryMethods

    class Infobip < DeliveryMethods::Base

      register_gateway "infobip"

      def initialize(user)
        super
        @client = OneApi::SmsClient.new(INFOBIP_KEY, INFOBIP_PASS)
      end

      def send_single_message(to, text)
        begin
          sms = OneApi::SMSRequest.new
          sms.address =  to
          sms.message = text

          result = client.send_sms(sms)
          # Store the client correlator to be able to query for the delivery status later:
          client_correlator = result.client_correlator
          return true
        rescue Exception => e
          log_error("Failed sending msg to: #{to}. #{e.message}")
          return false
        end
      end
  end
end
