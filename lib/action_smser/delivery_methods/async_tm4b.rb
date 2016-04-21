require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncTm4b < AsyncHttp
    include GatewayErrorInfo::Tm4bErrors

    def self.sms_info(sms)
      sms.number_from=random(10000...99999) unless sms.number_from!=nil
      msg = {
          :username => sms.delivery_options[gateway_key][:username],
          :password => sms.delivery_options[gateway_key][:password],
          :version => "2.2",
          :type => "broadcast",
          :from => '+'+sms.number_from.to_s+rand(1000000...9999999).to_s,
          :msg => sms.body,
          :to => sms.to.first,
          :concat => '1'
      }
      msg
    end

    def self.request_params(info, numbers, sms)
      msg=info.dup
      msg[:to] =numbers.join("%7C")
      return msg
    end

    def self.parse_response(response)
     if response[0..4]=='error'
       result= [{:msg_id=>'error',:code=>response[6..9],:message=>response[11..response.length-2]}]
     else
        result =[]
        dest=response["result"]["recipients"].to_i
        dest.times.each_with_index { |v,index | result << {:msg_id=> response["result"]["broadcastid"]+(index+1).to_s}}
     end
     return result
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      results.each_with_index do |res,index|
        msg_id = res[:msg_id]
        if !msg_id =='error'
          dr = ActionSmser::DeliveryReport.build_with_user(sms, sms.to[index], msg_id, user, route_name)
          count += 1
          dr.save
          sms.delivery_reports.push(dr)
        else
          ActionSmser::Logger.error "#{res[:message]}"
        end
      end
      count
    end

    def self.process_delivery_report(params)
      info = []
      status = case params["status"]
                 when "DELIVRD"
                   ActionSmserUtils::DELIVERED_STATUS
                 when "FAILED"
                   ActionSmserUtils::UNDELIVERED_STATUS
                 when "EXPIRED"
                   ActionSmserUtils::UNDELIVERED_STATUS
                 else
                   params["status"]
               end
      msg_id = params["id"]
      info << {"msg_id" => msg_id, "status" => status, "to" => params["recipient"]}
    end

    def self.path_url
     return "client/api/http.php"
    end

    def self.base_url
      "http://www.tm4b.com/"
    end

    def self.gateway_key
      :tm4b
    end
  end
end

