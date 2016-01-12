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
       #msg = info.dup
       # if numbers.count > 10
       #   msg["DA"]=numbers.first(10).join(",")
       # else
       #  msg["DA"]=numbers.join(",")
       # end

      #########################################################cambiando a request_body
       # msg["DA"]=numbers.first
       # return msg
    end


    def self.request_body(info, numbers, sms)
      msg = info.dup
      msg["DA"]=numbers.first
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
        error_code=res[:msg_id]
        if error_code.to_i > 0  # es que no hubo error
          count += 1
          dr = ActionSmser::DeliveryReport.build_with_user(sms,  sms.find_receiver_by_id(error_code), msg_id, user, route_name)
        else
          msg_id=nil
          dr = ActionSmser::DeliveryReport.build_with_user(sms, nil, msg_id, user, route_name) # aqui tiene que venir un numero
          dr.status= "SENT_ERROR_#{self.cardboardfish_error(error_code)}"
          dr.log += "error in request" if msg_id == nil
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
      count
    end

    def self.process_delivery_report(params)
      info = []
      inputparameter=params[:INCOMING]
      inputparameterArray=inputparameter.split("#")
      if inputparameterArray[0].to_i > 0
        inputparameterArray.last(inputparameterArray.count-1).each do |dr|
          row=dr.split(":")
          status = case row[3]
                     when "1"
                       ActionSmserUtils::DELIVERED_STATUS
                     when "3"
                       ActionSmserUtils::UNDELIVERED_STATUS
                     else
                       row[3]
                   end
          info << {"msg_id" => dr[0], "status" => status, "sender" => dr[1]}
        end
      end
      return info
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
