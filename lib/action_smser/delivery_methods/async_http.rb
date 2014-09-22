require 'em-http'
require 'action_smser_utils'
require 'gateway_error_info'

module ActionSmser::DeliveryMethods
  class AsyncHttp

    class << self
      attr_reader :path_url, :base_url, :r_head, :gateway_key
    end

    def self.deliver(sms)
      batch_size = sms.delivery_options[gateway_key][:numbers_in_request]
      concurrent_requests = sms.delivery_options[gateway_key][:parallel_requests]
      batches = sms.to_numbers_array.each_slice(batch_size).to_a
      last_request = batches.size
      user =  User.find(sms.user_id)
      route = Route.find(sms.route_id)
      em_was_running =  EM.reactor_running?
      count = 0
      info = self.sms_info(sms)

      EM.run do
        setup_middlewares
        connection = EM::HttpRequest.new(base_url)

        foreach = Proc.new do |numbers, iter|
          count +=1
          query_params = request_params(info, numbers, sms)
          body = request_body(info, numbers, sms)
          options = request_options(query_params, body, count < last_request)
          http = connection.post(options)

          http.callback do
            if succesful_response(http)
              results = parse_response(http.response)
              success_sms = save_delivery_reports(sms, results, user, route.name)
              user.bill_sms(success_sms, route.price)
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
          ActionSmser::Logger.info "Finished sending. #{Time.now}"
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


  end
end
