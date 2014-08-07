require 'securerandom'
require 'em-http'
require 'em-http/middleware/json_response'
require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncInfobip < AsyncHttp
    #http://api.infobip.com/api/v3/sendsms/json
    #@sender_address = cubacel_random_number
    @sender_address = ""
    @host = 'api.infobip.com'
    @base_url = "http://#{@host}/"
    @path_url = "/api/v3/sendsms/json"

    INFOBIP_HTTP_ERROR_CODES = {
       0  => "ALL_RECIPIENTS_PROCESSED",
      -1  => "SEND_ERROR",
      -2  => "NOT_ENOUGH_CREDITS",
      -3  => "NETWORK_NOT_COVERED",
      -5  => "INVALID_USER_OR_PASS",
      -6  => "MISSING_DESTINATION_ADDRESS",
      -10 => "MISSING_USERNAME",
      -11 => "MISSING_PASSWORD",
      -13 => "INVALID_DEST_ADDRESS",
      -22 => "SYNTAX_ERROR",
      -26 => "COMUNICATION_ERROR",
      -23 => "ERROR_PROCESSING",
      -27 => "INVALID_SEND_DATETIME",
      -28 => "INVALID_DLR_PUSH_URL",
      -30 => "INVALID_CLIENT_APPID",
      -33 => "DUPLICATE_MESSAGEID",
      -34 => "SENDER_NOT_ALLOWED",
      -99 => "GENERAL_ERROR",
    }

    class << self
      attr_reader :sender_address, :host
    end

    def self.deliver(sms)
      r_head = {:host => host, 'content-type' => 'application/json'}
      dest = {}# to associates each recipient or destination to the generated messageId
      info = self.sms_info(sms, dest)
      r_body = {authentication: {username: INFOBIP_KEY, password: INFOBIP_PASS }, messages: [info]}

      if USE_EM_PROXY
        connection_options = {
          host: EM_PHOST, port: EM_PPORT,
          authorization: [EM_PUSER, EM_PPASS]
        }
      else
        connection_options = {}
      end


      em_was_running =  EM.reactor_running?

      EM.run do
        connection = EM::HttpRequest.new(base_url, connection_options)
        connection.use EM::Middleware::JSONResponse

        options = self.request_options(r_head, nil, r_body)
        http = connection.post(options)

        http.callback do
          if sms.delivery_options[:save_delivery_reports]
            #save DLRs
            results = http.response["results"]
            self.save_delivery_reports(results, dest)
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
        recipients << {gsm: number, messageId: id }
        dest[id] = number
      end

      msg = {sender: sender_address, text: sms.body, recipients: recipients}
      if ActionSmser::Base.message_real_length(sms.body) > 160
        msg[:type] = "longSMS"
      end
      msg
    end

    def self.save_delivery_reports(results, dest)
      results.each do |res|
        error_code = res["status"].to_i
        sent_error =  error_code > 0
        dr_id = res["messageid"]
        dr = ActionSmser::DeliveryReport.build_from_sms(sms, dest[dr_id], dr_id)
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

    def self.cubacel_random_number
        result = "535"
        rand = Random.new
        7.times{ result << rand.rand(9).to_s}
        result
    end

  end
end
