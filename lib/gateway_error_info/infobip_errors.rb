module GatewayErrorInfo
  module InfobipErrors

    INFOBIP_HTTP_ERROR_CODES = {
       0  => "ALL_RECIPIENTS_PROCESSED",
      -1  => "SEND_ERROR",
      -2  => "NOT_ENOUGH_CREDITS",
      -3  => "NETWORK_NOT_COVERED",
      -5  => "INVALID_USER_OR_PASS",
      -6  => "MISSING_DESTINATION_ADDRESS",
      -10 => "MISSING_USERNAME",
      -11 => "MISSING_PASSWORD",
      -13 => "INVALID_DEST_ADDRESS",
      -22 => "SYNTAX_ERROR",
      -26 => "COMUNICATION_ERROR",
      -23 => "ERROR_PROCESSING",
      -27 => "INVALID_SEND_DATETIME",
      -28 => "INVALID_DLR_PUSH_URL",
      -30 => "INVALID_CLIENT_APPID",
      -33 => "DUPLICATE_MESSAGEID",
      -34 => "SENDER_NOT_ALLOWED",
      -99 => "GENERAL_ERROR",
    }

    module ClassMethods
      def infobip_error(error_code)
        INFOBIP_HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
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
