require_relative 'producer'
require_relative 'gateway'
require 'json'

module SmppTools

  @producers = Hash.new { |hash, key| hash[key] = Producer.create(Q_TYPE, key) }
  @gateways = Hash.new { |hash, key| hash[key] = SmppGateway.create(key, key, Rails.logger) }

  def self.get_producer(name)
    @producers[name]
  end

  def self.get_smpp_gateway(name)
    @gateways[name]
  end

  def self.connect_to_server(gateway)
    unless gateway.connected?
      config = load_config(gateway.name)
      gateway.connect(config)
    end
  end

  def self.load_config(gateway_name)
    #load from env
    result = {}
    str_data = ENV[gateway_name]
    result =  JSON.parse(str_data, symbolize_names: true) if str_data
    result
  end

  def self.save_config(gateway_name, config)
    s = {}
    config.each do |key, value|
      s[key.to_s] = value
    end
    ENV[gateway_name] = s.to_json
  end


end
