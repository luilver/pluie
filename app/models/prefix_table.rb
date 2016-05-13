class PrefixTable < ActiveRecord::Base
  has_many :gateway_prefixtables, :dependent => :destroy
  has_many :gateways, -> {distinct}, :through => :gateway_prefixtables
  validates :country_code, :uniqueness => true

  def price_gateway(name_gateway)
    return nil if Gateway.find_by_name(name_gateway).blank?
    gateway=Gateway.find_by_name(name_gateway)
    self.gateway_prefixtables.where(:gateway_id=> gateway.id).first.price.to_f || nil
  end
end
