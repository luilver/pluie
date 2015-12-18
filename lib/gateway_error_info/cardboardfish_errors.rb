module GatewayErrorInfo
  module CardboardfishErrors
    SUCCESS_CODE = 1

    HTTP_ERROR_CODES = {
        -5=>"Not_Enough_Credit",
        -10=>"Invalid_Username_Or_Password",
        -15=>"Invalid_destination_or_destination_not_covered",
        -20=>"System_error_",
        -25=>"Request_Error"

    }
    module ClassMethods
      def cardboardfish_error(error_code)
        #TODO: add smpp error. according
        HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
