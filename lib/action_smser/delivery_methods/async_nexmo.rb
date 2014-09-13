require_relative 'async_http'
require 'json'

module ActionSmser::DeliveryMethods
  class AsyncNexmo < AsyncHttp
    include GatewayErrorInfo::NexmoErrors
    @base_url = "https://rest.nexmo.com/"
    @path_url = "sms/json"
    @gateway_key = :nexmo
    @r_head = {'content-type' => 'application/json', "accept" => "*/*"}

    class << self
      attr_reader :r_head
    end

    def self.sms_info(sms)
      {
        "api_key" => sms.delivery_options[gateway_key][:username],
        "api_secret" => sms.delivery_options[gateway_key][:password],
        "from" => '+393484714262',
        "text" => sms.body,
        "status-report-req" => 1
      }
    end

    def self.request_body(info, numbers, sms)
      msg = info.dup
      msg["to"] = numbers.first
      msg.to_json
    end

    def self.parse_response(response)
      JSON.parse(response)["messages"]
    end

    def self.request_options( query_params, body, keepalive)
      options = super(query_params, body, keepalive)
      options.merge!({head: r_head})
    end

    def self.save_delivery_reports(sms, results,  user, route_name)
      error_code = 0
      msg_id = ""
      to = ""
      sent_error = false
      results.each do |msg|
        msg_id = msg["message-id"]
        error_code = msg["status"].to_i
        to = msg["to"]
        sent_error = error_code != 0
        break if sent_error
      end

      if sms.delivery_options[:inspect_request]
        ActionSmser::Logger.info "Nexmo Response: Status_Code:#{error_code}, Msg_id: #{msg_id}, To: #{to}"
      end

      dr = ActionSmser::DeliveryReport.build_with_user(sms, to, msg_id, user, route_name)
      if sent_error
        dr.status = "SENT_ERROR_#{nexmo_error(error_code)}"
      end
      dr.save
      return sent_error ? 0 : 1
    end

    def self.process_delivery_report(params)
      info = []
      if params["messageId"]
        info << {'msg_id' => params["messageId"], 'status' => params['status'].downcase}
      end
      info
    end

  end
end
