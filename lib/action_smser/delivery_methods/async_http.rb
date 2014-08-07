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

  end
end
