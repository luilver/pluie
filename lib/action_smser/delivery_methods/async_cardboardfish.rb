require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncCardboardfish < AsyncHttp
    include GatewayErrorInfo::CardboardfishErrors

    def self.sms_info(sms)
      sms.number_from=random(10000...99999) unless sms.number_from!=nil
      msg = {
          :UN => sms.delivery_options[gateway_key][:username],  # es case sensitive
          :P => sms.delivery_options[gateway_key][:password],   # es case sensitive
          :DA=>sms.to.first,
          :SA=>'+'+sms.number_from.to_s+rand(100000...999999).to_s, # aqui va un numero de longitud 16 o 11 caracteres alphanumerricos
          :M=>sms.body,
          :S=>'H', #en la doc ponen H por default
          :DR=>1,
          :ST=>1
      }
      msg
    end

    def self.request_body(info, numbers, sms)
       msg=info.dup
       msg[:DA]=numbers.join(",")
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
          dr = ActionSmser::DeliveryReport.build_with_user(sms,  sms.find_receiver_by_id(error_code), res[:msg_id], user, route_name)
        else
          dr = ActionSmser::DeliveryReport.build_with_user(sms, nil, res[:msg_id], user, route_name) # aqui tiene que venir un numero
          dr.status= "SENT_ERROR_#{self.cardboardfish_error(error_code)}"
          dr.log += "error in request" if res[:msg_id] == nil
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
      count
    end

    def self.process_delivery_report(params)
      info = []
      inputparameter=params['INCOMING']
      inputparameterArray=inputparameter.split("#")
      if inputparameterArray[0].to_i > 0
         input_callback=inputparameterArray[1].split(":")
          begin
          dr = ActionSmser::DeliveryReport.where(:msg_id=>input_callback[0]).first
          dr.to =input_callback[2]
          dr.save
          rescue
            ActionSmser::Logger.error "No existe ese msg_id in DR #{input_callback[0]}"
          end
          status = case input_callback[3]
                     when "1"
                       ActionSmserUtils::DELIVERED_STATUS
                     when "3"
                       ActionSmserUtils::UNDELIVERED_STATUS
                     else
                       input_callback[3]
                   end
          info << {"msg_id" => input_callback[0], "status" => status, "sender" => input_callback[1],"to"=> input_callback[2]}
      end
      return info
      end

    def self.path_url
     return "HTTPSMS?"
    end

    def self.base_url
      "http://sms2.cardboardfish.com:9001/"
    end

    def self.gateway_key
      :cardboardfish
    end
  end
end
