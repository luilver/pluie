module GatewayErrorInfo
  module NexmoErrors

    NEXMO_ERROR_CODES = {
       0  => "SUCCESS",
       1  => "THROTTLED",
       2  => "MISSING PARAMS",
       3  => "INVALID_PARAMS",
       4  => "INVALID_CREDENTIALS",
       5  => "INTERNAL_ERROR",
       6  => "INVALID_MESSAGE",
       7 => "NUMBER_BARRED",
       8 => "PARTNER_ACCOUNT_BARNED",
       9 => "PARTNER_QUOTA_EXCEEDED",
       11 => "ACCOUNT_NOT_ENABLED",
       12 => "MESSAGE_TO_LONG",
       13 => "COMMUNICATION_FAILED",
       14 => "INVALID_SIGNATURE",
       15 => "INVALID_SENDER",
       16 => "INVALID_TTL",
       19 => "FACILITY_NOT_ALLOWED",
       20 => "INVALID_MESSAGE_CLASS",
    }

    module ClassMethods
      def nexmo_error(error_code)
        NEXMO_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    module InstanceMethods

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
