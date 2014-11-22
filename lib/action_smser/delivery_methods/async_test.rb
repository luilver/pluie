require_relative 'async_http'

module ActionSmser::DeliveryMethods
  class AsyncTest < AsyncHttp

    def self.base_url
      "http://pluietests.local/"
    end

    def self.path_url
      "mocktests"
    end

    def self.gateway_key
      :test
    end

    def self.sms_info(sms)
      {:text => sms.body}
    end

    def self.request_params(info, numbers, sms)
      info.merge({:destination => numbers.join(",")})
    end
  end
end
