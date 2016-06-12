require_relative 'async_http'
require 'json'

module ActionSmser::DeliveryMethods
  class AsyncTwilio < AsyncHttp
    include GatewayErrorInfo::TwilioErrors

    def self.sms_info(sms)
      sms.number_from=random(10000...99999) unless sms.number_from!=nil
      msg = {
          :From => '+18444325936',
          :Body => sms.body,
          :To=> '+'+sms.to.first,
          :StatusCallback => 'http://sms.knal.es/delivery_reports/gateway_commit/twilio'
          #:StatusCallback => 'http://162.243.240.188/delivery_reports/gateway_commit/twilio'
      }
      msg
    end

    def self.request_body(info, numbers, sms)
      msg=info.dup
      return msg
    end

    def self.parse_response(response)
      ###response
      # "sid": "SM8756837dd3064155aae67511b6f14202",
      #     "date_created": "Thu, 17 Mar 2016 19:38:05 +0000",
      #     "date_updated": "Thu, 17 Mar 2016 19:38:05 +0000",
      #     "date_sent": null,
      # "account_sid": "ACfdd852891d1af661d851ad3f0e90fca3",
      #     "to": "+5358428432",
      #     "from": "+18444325936",
      #     "messaging_service_sid": null,
      # "body": "message twilio second time test1 ahora tarde conffaadda",
      #     "status": "queued",
      #     "num_segments": "1",
      #     "num_media": "0",
      #     "direction": "outbound-api",
      #     "api_version": "2010-04-01",
      #     "price": null,
      # "price_unit": "USD",
      #     "error_code": null,
      # "error_message": null,
      # "uri": "/2010-04-01/Accounts/ACfdd852891d1af661d851ad3f0e90fca3/Messages/SM8756837dd3064155aae67511b6f14202.json",
      #     "subresource_uris": {
      #     "media": "/2010-04-01/Accounts/ACfdd852891d1af661d851ad3f0e90fca3/Messages/SM8756837dd3064155aae67511b6f14202/Media.json"
      response = JSON.parse(response)
      return [{status: response['status'], dest: response['to'], msg_id:response['sid'],error_code:response['error_code']}]
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      list_numbers=[]
      results.each do |res|
        error_code=res[:error_code]
        number = res[:dest]
        number=number.to_s[1,number.size]
        msg_id = res[:msg_id]
        dr = ActionSmser::DeliveryReport.build_with_user(sms, number, msg_id, user, route_name)
        if error_code.nil? # aqui va los errors code
          count += 1
          list_numbers << number
        else
          dr.status= "SENT_ERROR_#{self.twilio_error(error_code)}"
          dr.log += "batch aborted" if msg_id == nil
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
      return count,list_numbers
    end

    def self.process_delivery_report(params)
      info = []
      status = case params[:MessageStatus]
                 when "delivered"
                   ActionSmserUtils::DELIVERED_STATUS
                 when "failed"
                   ActionSmserUtils::UNDELIVERED_STATUS
                 when "undelivered"
                   ActionSmserUtils::UNDELIVERED_STATUS
                 when "received"
                   ActionSmserUtils::DELIVERED_STATUS
                 when "sent"
                   ActionSmserUtils::SENT_STATUS
                 else
                   params[:sStatus]
               end
      msg_id = params[:MessageSid]
      sender = params[:From]
      info << {"msg_id" => msg_id, "status" => status, "sender" => sender}
    end

    def self.succesful_response(em_http)
      em_http.response_header.status == 201
    end

    def self.request_options(query_params, body, keepalive)
      options = {
          :path => path_url, :keepalive => keepalive,:head => {'authorization' => ['ACfdd852891d1af661d851ad3f0e90fca3', '41c666e9210711b0e17121f466a62e64']}
      }
      options[:query] = query_params if query_params
      options[:body] = body if body
      options
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
