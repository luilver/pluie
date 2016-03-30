module GatewayErrorInfo
  module FortytwoErrors
    SUCCESS_CODE = 0

    HTTP_ERROR_CODES = {
        SUCCESS_CODE  => "SUCCESS",
        1  => "BAD_LOGIN_DETAILS",
        2  => "PROBLEM_WITH_THE_MESSAGE",
        3  => "BAD_TO_NUMBER",
        4  => "NOT_ENOUGH_CREDITS_TO_SEND_MESSAGE",
        10  => "DELIVERED_TO_GATEWAY",
        11  => "DELIVERY_DELAYED",
        21  => "DELIVERED_TO_NETWORK",
        30  => "NO_CREDIT_COVERAGE",
        41  => "MALFORMED_MESSAGE",
        42  => "INTERNAL_ERROR",
        44  => "MESSAGE_EXPIRED_WITHOUT_DELIVERY",
        50  => "GENERAL_DELIVERY_PROBLEM"
    }
    module ClassMethods
      def fortytwo_error(error_code)
        #TODO: add smpp error. according
        HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
