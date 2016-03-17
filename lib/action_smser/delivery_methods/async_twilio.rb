require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncTwilio < AsyncHttp
    include GatewayErrorInfo::TwilioErrors

    def self.sms_info(sms)
      sms.number_from=random(10000...99999) unless sms.number_from!=nil
      msg = {
          :From => '+18444325936',
          :Body => sms.body,
          :To=> '+'+sms.to.first
      }
      msg
    end


    def self.save_delivery_reports(sms, results, user, route_name)

    end

    def self.process_delivery_report(params)

    end

    def self.path_url
     return "2010-04-01/Accounts/ACfdd852891d1af661d851ad3f0e90fca3/Messages.json"
    end

    def self.base_url
      "https://api.twilio.com/"
    end

    def self.gateway_key
      :twilio
    end
  end
end
