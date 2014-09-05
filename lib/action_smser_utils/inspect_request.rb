module ActionSmserUtils
  class InspectRequest
    def request(client, head, body)
      ActionSmser::Logger.info "===Request Head==="
      ActionSmser::Logger.info head.inspect
      ActionSmser::Logger.info "===Request Body==="
      ActionSmser::Logger.info body.inspect
      [head, body]
    end
  end
end
