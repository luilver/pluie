require_relative 'async_http'
require 'oneapi-ruby'
require 'em-http'
require 'em-http/middleware/json_response'

module DeliveryMethods

    class Infobip < DeliveryMethods::AsyncHttp

      register_subclass "infobip_http"

      def initialize(user)
        super
        @client = OneApi::SmsClient.new(INFOBIP_KEY, INFOBIP_PASS)
        @base_url = "http://api.infobip.com/"
        @sender_address = cubacel_random_number.to_s
        @path_url = "/api/v3/sendsms/json"
        # en oneapi, de infobip, al parecer identifica al numero que envia el sms
        #buscar si puede ser aleatorio o no
      end

      def send_sms(sms_list)
        http = []

        EM.run do

          sms_list.each_with_index do |sms, index|
            params = get_params_from_sms(sms)
            options = request_options(nil, params)
            conn =  EM::HttpRequest.new(base_url, connection_options)
            conn.use EM::Middleware::JSONResponse
            http << conn.post(options)
            h = http[index]
            h.callback do
              msg_id = h.response['clientCorrelator']
              log_info("Sended msg: #{msg_id} using infobip_http" )
            end

            h.errback do
              #Log error
            end


          end
        end

      end

      def get_params_from_sms(sms)
        {
          :senderAddress => @senderAddress,
          :address => sms.receiver,
          :message => sms.text,
          :clientCorrelator => sms.id.to_s,
        }
            #params['notifyURL'] = sms.notify_url  #buscar, pero debe ser para definir una url a donde dar el delivery report
      end

      protected
        def request_options(query, body, keepalive= false)
          options = super(query, body, keepalive)
          head = options[:head] || {}
          head[:authorization] = [INFOBIP_KEY, INFOBIP_PASS]
          options[:head] = head
          options
        end
  end
end
