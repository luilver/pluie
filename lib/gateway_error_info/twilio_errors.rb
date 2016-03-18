module GatewayErrorInfo
  module TwilioErrors

    HTTP_ERROR_CODES = {
        20006 => "Access_Denied",
        21102  => "Invalid_Access_Token",
        21102 => "Invalid_Access_Token_header",
        21104 => "Access_Token_expired_or_expiration_date_invalid",
        21205 => "Invalid Url",
        21211  => "Invalid_To_Phone_Number",
        21231 => "Domain_Validation_Error",
        21212  => "Invalid_From_Phone_Number",
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
