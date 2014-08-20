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

    class << self
      attr_reader :sender_address, :host
    end

    def self.deliver(sms)
      dest = {}# to associates each recipient or destination to the generated messageId
      info = self.sms_info(sms, dest)
      r_head = {"host" => host, 'content-type' => 'application/json', "accept" => "*/*"}
      r_body = {"authentication" => {"username" => INFOBIP_KEY, "password" => INFOBIP_PASS }, "messages" => [info]}
      r_body = r_body.to_json
      conn_options = self.connection_options()
      user_id = sms.user_id
      em_was_running =  EM.reactor_running?

      EM.run do
        connection = EM::HttpRequest.new(base_url, conn_options)
        http = connection.post(:head => r_head, :body => r_body, :path => path_url, :keepalive => false)

        http.callback do
          results = JSON.parse(http.response)["results"] rescue nil
          if results
            self.save_delivery_reports(sms, results, dest, user_id)
          else
            ActionSmser::Logger.error "Empty results in http response. #{Time.now}"
          end
          EventMachine.stop unless em_was_running
        end

        http.errback do
          #TODO... Log de los e
          ActionSmser::Logger.error "Async infobip conn error: #{http.response.inspect} at #{Time.now}"
          EventMachine.stop unless em_was_running
        end
      end
    end

    def self.sms_info(sms, dest)
      recipients = []
      sms.to_numbers_array.each do |number|
        id = SecureRandom.uuid()
        recipients << {"gsm" => number, "messageId" => id }
        dest[id] = number
      end

      msg = {"text" => sms.body, "recipients" => recipients,
            "drPushUrl" => ActionSmserUtils.gateway_callback_url(:infobip)}
      if ActionSmser::Base.message_real_length(sms.body) > 160
        msg["type"] = "longSMS"
      end
      msg
    end

    def self.save_delivery_reports(sms, results, dest, user_id)
      cost = 0
      begin
        user = User.find(user_id) rescue nil
        msg_cost = self.calculate_msg_cost(sms, :infobip)

        results.each do |res|
          error_code = res["status"].to_i
          sent_error =  error_code < 0
          msg_id = res["messageid"]
          dr = ActionSmser::DeliveryReport.build_from_sms(sms, dest[msg_id], msg_id)
          dr.user = user
          if sent_error
            dr.status = "SENT_ERROR_#{error_code}"
            dr.log += "infobip error: #{self.infobip_error(error_code)}"
          else
            cost+= msg_cost
          end
          dr.save
          sms.delivery_reports.push(dr)
        end
      rescue Exception => e
        ActionSmser::Logger.error "Fail saving DLRs. #{e.message}.\n Trace: #{e.backtrace.join("\n")}"
      ensure
        user.decrease_balance(cost) if user
      end
    end

    def self.process_delivery_report(params)
      dlrs_info = []
      ActionSmser::Logger.info "DeliveryReport update from infobip."
      ActionSmser::Logger.info "Params: #{params.inspect}"
      #TODO... return an array with the updated values for the delivery report
      dlrs_info
    end

  end
end
