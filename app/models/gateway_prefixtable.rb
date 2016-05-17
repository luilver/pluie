class GatewayPrefixtable < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :prefix_table
  before_create :distinct_prefix

  def prefix_cc
    self.prefix_table.country_code
  end

  def name_gateway
    self.gateway.name
  end

  def distinct_prefix
    return GatewayPrefixtable.where(:gateway_id=>self.gateway_id, :prefix_table_id=>self.prefix_table_id).blank?
  end
end
