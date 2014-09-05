module GatewayErrorInfo
  module RoutesmsErrors
    HTTP_ERROR_CODES = {
       1701  => "SUCESS",
       1702  => "INVALID_URL",
       1703  => "INVALID_USER_OR_PASS",
       1704  => "INVALID_MSG_TYPE",
       1705  => "INVALID_MESSAGE",
       1706  => "INVALID_DEST_ADDRESS",
       1707  => "INVALID_SOURCE",
       1708  => "INVALID_DLR_FIELD",
       1709  => "USER_VALIDATION_FAILED",
       1710  => "INTERNAL_ERROR",
       1025  => "NOT_ENOUGH_CREDITS",
       1032  => "DESTINATION_IN_DND",
       1033  => "SENDER_TEMPLATE_MISMATCH",
    }
    module ClassMethods
      def routesms_error(error_code)
        #TODO: add smpp error. according
        HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
