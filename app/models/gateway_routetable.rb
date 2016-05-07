class GatewayRoutetable < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :route_table
end
