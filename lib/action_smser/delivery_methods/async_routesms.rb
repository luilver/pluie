require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncRoutesms < AsyncHttp
    #:path_url, :base_url, :r_head, :r_body, :gateway_key
    @path_url = "bulksms/bulksms"
    @base_url = "http://smsplus1.routesms.com:8080/"
    #@r_head =  nil # ver si basta con no declarlo
    @gateway_key = :routesms

    def self.sms_info(sms)
      msg = {
        :username => sms.delivery_options[gateway_key][:username],
        :password => sms.delivery_options[gateway_key][:password],
        :type => 0,
        :dlr => 1,
        :source => cubacel_random_number,
        :message => sms.body
      }
      msg
    end

    def self.request_params(info, numbers, sms)
      destination =  numbers.join(",")
      info.merge({:destination => destination})
    end

    def self.parse_response(response)
      #devolver array de results
      chunks = response.split(",")
      results = chunks.map do |c|
        status, dest, msg_id = c.split("|")
        {status: status.to_i, dest: dest, msg_id: msg_id}
      end
      results
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      count = 0

      count
    end

  end
end
