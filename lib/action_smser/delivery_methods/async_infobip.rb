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
      r_head = {"host" => host, 'content-type' => 'application/json', "accept" => "*/*"}
      dest = {}# to associates each recipient or destination to the generated messageId
      info = self.sms_info(sms, dest)
      r_body = {"authentication" => {"username" => INFOBIP_KEY, "password" => INFOBIP_PASS }, "messages" => [info]}
      r_body = r_body.to_json
      conn_options = self.connection_options()

      em_was_running =  EM.reactor_running?

      EM.run do
        connection = EM::HttpRequest.new(base_url, conn_options)
        http = connection.post(:head => r_head, :body => r_body, :path => path_url, :keepalive => false)

        http.callback do
          results = JSON.parse(http.response)["results"] rescue nil
          if results
            self.save_delivery_reports(sms, results, dest)
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

      msg = { "text" => sms.body, "recipients" => recipients}
      if ActionSmser::Base.message_real_length(sms.body) > 160
        msg["type"] = "longSMS"
      end
      msg
    end

    def self.save_delivery_reports(sms, results, dest)
      results.each do |res|
        error_code = res["status"].to_i
        sent_error =  error_code > 0
        msg_id = res["messageid"]
        dr = ActionSmser::DeliveryReport.build_from_sms(sms, dest[msg_id], msg_id)
        if sent_error
          dr.status = "SENT_ERROR_#{error_code}"
          dr.log += "infobip error: #{self.infobip_error(error_code)}"
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
    end

    def self.infobip_error(error_code)
      INFOBIP_HTTP_ERROR_CODES[error_code] || "UNKNOWN_ERROR"
    end



  end
end
