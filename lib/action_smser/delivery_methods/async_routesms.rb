require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncRoutesms < AsyncHttp
    include GatewayErrorInfo::RoutesmsErrors

    def self.sms_info(sms)
      msg = {
        :username => sms.delivery_options[gateway_key][:username],
        :password => sms.delivery_options[gateway_key][:password],
        :type => 0,
        :dlr => 1,
        :source => '+39'+sms.number_from.to_s+rand(99999).to_s,
        :message => sms.body
      }
      msg
    end

    def self.request_params(info, numbers, sms)
      info.merge({:destination => numbers.join(",")})
    end

    def self.parse_response(response)
      chunks = response.split(",")
      results = chunks.map do |c|
        status, dest, msg_id = c.split("|")
        {status: status.to_i, dest: dest, msg_id: msg_id}
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
      info << {"msg_id" => msg_id, "status" => status, "sender" => sender,"sMobileNo" => params[:sMobileNo]}
    end

    def self.path_url
      "bulksms/bulksms"
    end

    def self.base_url
      "http://smsplus1.routesms.com:8080/"
    end

    def self.gateway_key
      :routesms
    end
  end
end
