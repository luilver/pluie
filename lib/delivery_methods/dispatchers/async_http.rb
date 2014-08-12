require_relative 'base'

module DeliveryMethods
  class AsyncHttp < DeliveryMethods::Base

    attr_reader :base_url, :path_url
    attr_accessor :connection_options

    def initialize(user)
      super
      @connection_options = {}
      if USE_EM_PROXY
        @connection_options[:proxy] = proxy_options
      end
    end

    protected
      def request_options(query, body, keepalive= false)
        h = {
          path: path_url,
          keepalive: keepalive
        }
        h[:query] = query if query && !query.empty?
        h[:body] = body if body && !body.empty?
      end

    private
      def proxy_options
        {
          host: EM_PHOST, port: EM_PPORT,
          authorization: [EM_PUSER, EM_PPASS]
        }
      end

  end
end
