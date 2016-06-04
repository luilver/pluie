class AddpriceCostTogatewayRoutetables < ActiveRecord::Migration
  def change
    add_column :gateway_routetables, :price_cost, :float
  end
end
