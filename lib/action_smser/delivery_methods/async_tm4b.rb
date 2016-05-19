require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncTm4b < AsyncHttp
    include GatewayErrorInfo::Tm4bErrors


    def self.deliver(sms)
      batch_size = sms.delivery_options[gateway_key][:numbers_in_request]
      concurrent_requests = sms.delivery_options[gateway_key][:parallel_requests]
      batches = sms.to_numbers_array.each_slice(batch_size).to_a
      last_request = batches.size
      route = Route.find(sms.route_id)
      user = Bill.find(sms.bill_id).user
      em_was_running =  EM.reactor_running?
      request_counter = 0
      info = self.sms_info(sms)
      success = 0

      EM.run do
        setup_middlewares
        connection = EM::HttpRequest.new(base_url)

        foreach = Proc.new do |numbers, iter|
          request_counter +=1
          query_params = request_params(info, numbers, sms)
          body = request_body(info, numbers, sms)
          options = request_options(query_params, body, request_counter < last_request)
          http=connection.get(options)

          http.callback do
            if succesful_response(http)
              results = parse_response(http.response)
              success += save_delivery_reports(sms, results, user, route.name)
            else
              log_response(http)
            end
            iter.next
          end

          http.errback do
            ActionSmser::Logger.error "Connection error\n"
            iter.next
          end
        end

        final = Proc.new do
          ActionSmser::Logger.info "Finished sending with route #{route}. #{Time.now}"
          sms.broadcast_delivery_finished(success)
          EventMachine.stop unless em_was_running
        end
        EM::Iterator.new(batches, concurrent_requests).each(foreach, final)
      end
    end


    def self.sms_info(sms)
      sms.number_from=random(10000...99999) unless sms.number_from!=nil
      msg = {
          "username" => sms.delivery_options[gateway_key][:username],
          "password" => sms.delivery_options[gateway_key][:password],
          "version" => "2.1",
          "type" => "broadcast",
          "from" => '5352644047',
          "msg" => sms.body,
          "to" => sms.to.first,
          "concat" => '1'
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
        response=Hash.from_xml(response)
        dest=response["result"]["recipients"].to_i
        dest.times.each_with_index { |v,index | result << {:msg_id=> response["result"]["broadcastID"]+(index+1).to_s}}
     end
     return result
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0
      results.each_with_index do |res,index|
        msg_id = res[:msg_id]
        if !(msg_id =='error')
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

