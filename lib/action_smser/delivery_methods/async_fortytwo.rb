require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncFortytwo < AsyncHttp
    include GatewayErrorInfo::FortytwoErrors

    def self.sms_info(sms)
      msg = {
          :username => sms.delivery_options[gateway_key][:username],
          :password => sms.delivery_options[gateway_key][:password],
          :to=> sms.to,
          :from => '43380',
          :message => sms.body,
          :route=>'G1'
      }
      msg
    end

    def self.request_body(info, numbers, sms)
      msg=info.dup
      return msg
    end

    def self.parse_response(response)
        chunks = response.split("\n") # si el conjunto de messages enviados cada response viene en una linea
        results = chunks.map do |c|
        gatewaystatus, messageid, destination = c.split(",")
        {status: gatewaystatus.to_i, dest: destination, msg_id: messageid}
      end
      results
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      results.each do |res|
        gatewaystatus = res[:status]
        number = res[:dest]
        msg_id = res[:msg_id]
        dr = ActionSmser::DeliveryReport.build_with_user(sms, number, msg_id, user, route_name)
        if gatewaystatus == 22
          count += 1
        else
          dr.status= "SENT_ERROR_#{self.fortytwo_error(msg_id)}"
          dr.log += "batch aborted" if gatewaystatus == 0 #gatewaystatus 0 ocurrio un error
        end
        dr.save
        sms.delivery_reports.push(dr)
      end
      count
    end

    def self.process_delivery_report(params)
      info = []
      status = case params[:status]
                 when "22"
                   ActionSmserUtils::DELIVERED_STATUS
                 when "10"
                   ActionSmserUtils::SENT_STATUS
                 when "11"
                   ActionSmserUtils::SENT_STATUS
                 when "21"
                   ActionSmserUtils::SENT_STATUS
                 else
                   ActionSmserUtils::UNDELIVERED_STATUS
               end
      msg_id = params[:smsid]
      sender = params[:from]
      info << {"msg_id" => msg_id, "status" => status, "sender" => sender}
    end

    def self.path_url
      "api/current/send/message.php"
    end

    def self.base_url
      "http://server2.msgtoolbox.com/"
    end

    def self.gateway_key
      :fortytwo
    end
  end
end
