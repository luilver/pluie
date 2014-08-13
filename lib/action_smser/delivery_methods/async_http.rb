module ActionSmser::DeliveryMethods
  class AsyncHttp

    class << self
      attr_reader :path_url, :base_url
    end

    def self.request_options(head = {}, query = {}, body = {}, keepalive= false)
        h = {
              keepalive: keepalive,
              path_url: path_url
            }
        h[:query] = query if query
        h[:body] = body if body
        h[:head] = head if head
        h
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

  end
end
