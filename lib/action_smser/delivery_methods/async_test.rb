require_relative 'async_http'
require 'json'
require 'securerandom'

module ActionSmser::DeliveryMethods
  class AsyncTest < AsyncHttp
    @@deliveries = []
    def self.deliveries
      @@deliveries
    end

    def self.full_url
      "#{base_url}/#{path_url}"
    end

    def self.base_url
      "http://localhost"
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

    def self.request_body(info, numbers, sms)
      info.merge({:numbers => numbers.to_a}).to_json
    end

    def self.request_options( query_params, body, keepalive)
      options = super(query_params, body, keepalive)
      options.merge!({head: {'content-type' => 'application/json', "accept" => "*/*"}})
    end

    def self.parse_response(response)
      res = JSON.parse(response)
    end

    def self.save_delivery_reports(sms, results, user, route_name)
      self.deliveries << sms
      count = 0
      results.each do |result|
        count += 1
        dr = ActionSmser::DeliveryReport.build_with_user(sms, result["number"], result["id"], user, route_name)
        dr.save
        sms.delivery_reports.push(dr)
      end
      count
    end

    def self.generate_response_from_body(body)
      data = JSON.parse(body)
      res = data["numbers"].map {|num| {number: num, id: SecureRandom.uuid()}}
      res.to_json
    end
  end
end
