class GatewayPrefixtable < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :prefix_table

  def prefix_cc
    self.prefix_table.country_code
  end

  def name_gateway
    self.gateway.name
  end
end
