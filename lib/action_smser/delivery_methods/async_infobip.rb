require 'securerandom'
require_relative 'async_http'
require 'gateway_error_info'
require 'json'

module ActionSmser::DeliveryMethods
  class AsyncInfobip < AsyncHttp
    include GatewayErrorInfo::InfobipErrors

    #http://api.infobip.com/api/v3/sendsms/json
    #@sender_address = cubacel_random_number
    @sender_address = ""
    @host = 'api.infobip.com'
    @base_url = "http://#{@host}/"
    @path_url = "api/v3/sendsms/json"
    @gateway_key = :infobip
    @r_head = {"host" => @host, 'content-type' => 'application/json', "accept" => "*/*"}
    @r_body = {"authentication" => {"username" => INFOBIP_KEY, "password" => INFOBIP_PASS }}


    class << self
      attr_reader :sender_address, :host, :r_body, :r_head
    end

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
      if ActionSmser::Base.message_real_length(sms.body) > 160
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
          end
          dr.save
          sms.delivery_reports.push(dr)
        end
      rescue Exception => e
        ActionSmser::Logger.error "Fail saving DLRs. #{e.message}.\n Trace: #{e.backtrace.join("\n")}"
      end
      count
    end

    def self.process_delivery_report(params)
      info = []
      if params["DeliveryReport"] && (msg = params["DeliveryReport"]["message"])
        dlrs_array = msg.is_a?(Array) ? msg : [msg]
        dlrs_array.each do |dlr|
          stat = dlr["status"]
          stat += "_with_GSM_ERROR_#{dlr["gsmerror"]}" unless dlr["gsmerror"].eql?("0")

          info << {
                    "msg_id" => dlr["id"], "status" => stat,
                    "status_updated_at" => DateTime.parse(dlr["donedate"])
                  }
        end
      end
      info
    end

    def self.request_options( query_params, body, keepalive)
      options = super(query_params, body, keepalive)
      options.merge!({head: r_head})
    end

  end
end
