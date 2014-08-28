require 'securerandom'
require 'em-http'
require 'em-http/middleware/json_response'
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
      attr_reader :sender_address, :host, :gateway_key, :r_head, :r_body
    end

    def self.deliver(sms)
      batch_size = sms.delivery_options[gateway_key][:numbers_in_request]
      concurrent_requests = sms.delivery_options[gateway_key][:parallel_requests]
      batches = sms.to_numbers_array.each_slice(batch_size).to_a
      last_request = batches.size

      info = self.sms_info(sms)
      user =  User.find(sms.user_id)
      em_was_running =  EM.reactor_running?
      count = 0

      EM.run do
        connection = EM::HttpRequest.new(base_url)

        foreach = Proc.new do |numbers, iter|
          count +=1
          msg = self.build_msg(info, numbers, sms)
          body = r_body.dup
          body["messages"] = [msg]

          http = connection.post(:head => r_head, :body => body.to_json, :path => path_url, :keepalive => count < last_request)

          http.callback do
            results = JSON.parse(http.response)["results"] rescue nil
            if results
              route = Route.find(sms.route_id)
              success_sms = self.save_delivery_reports(sms, results, user, route.name)
              user.bill_sms(success_sms, route.price)
            else
              ActionSmser::Logger.error "Empty results in http response. #{Time.now}"
            end
            iter.next
          end

          http.errback do
            #TODO... Log de los e
            ActionSmser::Logger.error "Async infobip conn error: #{http.response.inspect} at #{Time.now}"
            iter.next
          end

        end

        final = Proc.new do
          ActionSmser::Logger.info "Finished sending. #{Time.now}"
          EventMachine.stop unless em_was_running
        end

        EM::Iterator.new(batches, concurrent_requests).each(foreach, final)
      end
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
            dr.status = "SENT_ERROR_#{error_code}"
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

  end
end
