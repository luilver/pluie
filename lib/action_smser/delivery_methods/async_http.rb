require 'em-http'
require 'action_smser_utils'
require 'gateway_error_info'

module ActionSmser::DeliveryMethods
  class AsyncHttp

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
          http=connection.post(options)

          http.callback do
            if succesful_response(http)
               results = parse_response(http.response)
               success += save_delivery_reports(sms, results, user, route.name)
            success=1
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

    def self.cubacel_random_number
      result = "535"
      rand = Random.new
      7.times{ result << rand.rand(9).to_s}
      result
    end

    #Default values in case that one of them is not
    #used to send information to the gateway
    def self.request_body(info, numbers, sms)
      nil
    end

    def self.request_params(info, numbers, sms)
      nil
    end

    def self.request_options( query_params, body, keepalive)
      options = {
        :path => path_url, :keepalive => keepalive
      }
      options[:query] = query_params if query_params
      options[:body] = body if body
      options
    end

    def self.succesful_response(em_http)
      em_http.response_header.status == 200
    end

    def self.log_response(em_http)
      ActionSmser::Logger.error "Response from #{base_url}:\n#Time: #{Time.current}\nStatus:#{em_http.response_header.status}\nHeader:#{em_http.response_header}"
    end

    def self.setup_middlewares
      m = ActionSmserUtils::InspectRequest
      EM::HttpRequest.use m if Rails.env.development? && !EM::HttpRequest.middleware.include?(m.new)
    end

    def self.path_url
    end

    def self.base_url
    end

    def self.r_head
    end

    def self.gateway_key
    end
  end
end
