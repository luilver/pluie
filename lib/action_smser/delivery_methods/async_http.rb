module ActionSmser::DeliveryMethods
  class AsyncHttp

    class << self
      attr_reader :path_url, :base_url
    end

    def self.connection_options(options = {})
      connection_options = {}
      if USE_EM_PROXY
        connection_options[:host] = EM_PHOST
        connection_options[:port] = EM_PPORT
        connection_options[:authorization] = [EM_PUSER, EM_PPASS]
      end
      connection_options.merge!(options)
    end

    def self.cubacel_random_number
        result = "535"
        rand = Random.new
        7.times{ result << rand.rand(9).to_s}
        result
    end
  end
end
