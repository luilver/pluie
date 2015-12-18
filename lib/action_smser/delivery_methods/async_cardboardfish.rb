require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncCardboardfish < AsyncHttp
    include GatewayErrorInfo::CardboardfishErrors

    def self.sms_info(sms)
      msg = {
          :UN => sms.delivery_options[gateway_key][:username],  # es case sensitive
          :P => sms.delivery_options[gateway_key][:password],   # es case sensitive
          :DA=>sms.to,
          :SA=>'5358428432225559', # aqui va un numero de longitud 16 o 11 caracteres alphanumerricos
          :M=>sms.body,
          :S=>'H', #en la doc ponen H por default
          :DR=>1
      }
      msg
    end

    def self.request_params(info, numbers, sms)
       msg = info.dup
       if numbers.count > 10
         msg["DA"]=numbers.first(10).join(",")

       else
        msg["DA"]=numbers.join(",")
       end
       return msg
    end

    def self.parse_response(response)
      chunks =response.split(" ")
      chunks=chunks.select{|k| k!= "OK"}
      results =chunks.map do |c|
        {:msg_id=>c}
      end
      results
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      results.each do |res|
        error_code = res[:status]
        number = res[:dest]
        msg_id = res[:msg_id]
        dr = ActionSmser::DeliveryReport.build_with_user(sms, number, msg_id, user, route_name)
        if error_code == GatewayErrorInfo::RoutesmsErrors::SUCCESS_CODE
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
      info = []
      status = case params[:sStatus]
                 when "DELIVRD"
                   ActionSmserUtils::DELIVERED_STATUS
                 when "UNDELIV"
                   ActionSmserUtils::UNDELIVERED_STATUS
                 else
                   params[:sStatus]
               end
      msg_id = params[:sMessageId]
      sender = params[:sSender]
      info << {"msg_id" => msg_id, "status" => status, "sender" => sender}
    end

    def self.path_url
      "HTTPSMS?"
    end

    def self.base_url
      "http://sms2.cardboardfish.com:9001/"
    end

    def self.gateway_key
      :cardboardfish
    end
  end
end
