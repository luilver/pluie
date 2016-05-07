class RouteTable < ActiveRecord::Base
  has_many :gateway_routetables
  has_many :gateways, -> {distinct}, :through => :gateway_routetables

  def price_gateway(name_gateway)
    return nil if Gateway.find_by_name(name_gateway).blank?
    gateway=Gateway.find_by_name(name_gateway)
    self.gateway_routetables.where(:gateway_id=> gateway.id).first.price.to_f || nil
  end
end
