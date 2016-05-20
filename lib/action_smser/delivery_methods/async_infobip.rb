require 'securerandom'
require_relative 'async_http'
require 'json'

module ActionSmser::DeliveryMethods
  class AsyncInfobip < AsyncHttp
    include GatewayErrorInfo::InfobipErrors

    def self.request_body(info, numbers, sms)
      msg = self.build_msg(info, numbers, sms)
      body = r_body.merge({"messages" => [msg]})
      body.to_json
    end

    def self.parse_response(response)
      JSON.parse(response)["results"] rescue nil
    end

    def self.sms_info(sms)
      msg = {"text" => sms.body, "drPushUrl" => ActionSmserUtils.gateway_callback_url(gateway_key)}
      if sms.concatenated?
        msg["type"] = "longSMS"
      end
      msg
    end

    def self.build_msg(msg_info, numbers, sms)
      info = msg_info.dup
      recipients = []
      numbers.each do |number|
        id = SecureRandom.uuid()
        recipients << {"gsm" => number, "messageId" => id }
        sms.receivers_hash[id] = number
      end
      info["recipients"] = recipients
      info
    end

    def self.save_delivery_reports(sms, results,  user, route_name)
      count = 0
      list_numbers=[]
      begin
        results.each do |res|
          error_code = res["status"].to_i
          sent_error =  error_code < 0
          msg_id = res["messageid"]
          dr = ActionSmser::DeliveryReport.build_with_user(sms, sms.find_receiver_by_id(msg_id), msg_id, user, route_name)
          if sent_error
            dr.status = "SENT_ERROR_#{self.infobip_error(error_code)}"
            dr.log += "infobip error: #{self.infobip_error(error_code)}"
          else
            count += 1
            list_numbers << sms.find_receiver_by_id(msg_id)
          end
          dr.save
          sms.delivery_reports.push(dr)
        end
      rescue Exception => e
        ActionSmser::Logger.error "Fail saving DLRs. #{e.message}.\n Trace: #{e.backtrace.join("\n")}"
      end
      return count,list_numbers
    end

    def self.process_delivery_report(params)
      info = []
      if params["DeliveryReport"] && (msg = params["DeliveryReport"]["message"])
        dlrs_array = msg.is_a?(Array) ? msg : [msg]
        dlrs_array.each do |dlr|
          s = dlr["status"].downcase
          stat = case s
          when "delivered"
            ActionSmserUtils::DELIVERED_STATUS
          when "not_delivered"
            ActionSmserUtils::UNDELIVERED_STATUS
          else
            s
          end
          stat += "_with_GSM_ERROR_#{dlr["gsmerror"]}" unless dlr["gsmerror"].eql?("0")
          info << {"msg_id" => dlr["id"], "status" => stat}
        end
      end
      info
    end

    def self.request_options( query_params, body, keepalive)
      options = super(query_params, body, keepalive)
      options.merge!({head: r_head})
    end

    def self.account_balance_url(key, pass)
      "http://api.infobip.com/api/command?username=#{key}&password=#{pass}&cmd=CREDIT"
    end

    def self.host
      'api.infobip.com'
    end
    def self.r_head
      {"host" => host, 'content-type' => 'application/json', "accept" => "*/*"}
    end

    def self.r_body
      {"authentication" => {"username" => INFOBIP_KEY, "password" => INFOBIP_PASS }}
    end

    def self.gateway_key
      :infobip
    end

    def self.base_url
      "http://#{host}/"
    end

    def self.path_url
      "api/v3/sendsms/json"
    end
  end
end
