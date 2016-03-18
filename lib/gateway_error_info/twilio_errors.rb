module GatewayErrorInfo
  module TwilioErrors

    HTTP_ERROR_CODES = {
        30001  => "Queue_overflow",
        30002  => "Account_suspended",
        30003  => "Unreachable_destination_handset",
        30004  => "Message_blocked",
        30005  => "Unknown_destination_handset",
        30006  => "Landline_or_unreachable_carrier",
        30007  => "Carrier_violation",
        30008  => "Unknown_error",
        30009  => "Missing_segment",
        30010  => "Message_price_exceeds_max_price"
    }
    module ClassMethods
      def twilio_error(error_code)
        #TODO: add smpp error. according
        HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
