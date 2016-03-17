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

      return [{status: response['status'], dest: response['to'], msg_id:response['sid']}]
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      results.each do |res|
        error_code = res[:status]
        number = res[:dest]
        msg_id = res[:msg_id]
        dr = ActionSmser::DeliveryReport.build_with_user(sms, number, msg_id, user, route_name)
        if error_code == null # aqui va los errors code
          count += 1
        else
          dr.status= "SENT_ERROR_#{self.routesms_error(error_code)}"
          dr.log += "batch aborted" if msg_id == nil
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
      count
    end

    def self.process_delivery_report(params)
    end

    def self.succesful_response(em_http)
      em_http.response_header.status == 201
    end

    def self.request_options( query_params, body, keepalive)
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
