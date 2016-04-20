module GatewayErrorInfo
  module Tm4bErrors
    SUCCESS_CODE = 1701

    HTTP_ERROR_CODES = {

        001  => "value_for_a_mandatory_parameter_could_not_be_found",
        002  => "credentials_could_not_be_verified",
        003  => "unsupported_version_of_the_SMS_API",
        004  => "An_invalid_value_has_been_supplied",
        005  => "The_destination_country_cannot_be_identified",
        006  => "An_invalid_combination_of_values",
        007  => "An_invalid_HTTP_method ",
        008  => "The_ratio_of_messages_to_recipients_is_not_valid",
        009  => "The_maximum_number_of_recipients_has_been_exceeded",
        010  => "Insufficient_credits_on_the_relevant_balance",
        012  => "The_specified_subscription_service_has_expired.",
        013  => "An_attempt_to_send_MT_SMS_to_a_non_test",
        014  => "The_requested_keyword_is_not_available_on_any_shared_number"
    }
    module ClassMethods
      def tm4b_error(error_code)
        #TODO: add smpp error. according
        HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
      end

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end
