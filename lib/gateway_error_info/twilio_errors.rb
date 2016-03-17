module GatewayErrorInfo
  module TwilioErrors

    module ClassMethods
      def twilio_error(error_code)
        #TODO: add smpp error. according
         "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
