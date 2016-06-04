class CreateGatewayRoutetables < ActiveRecord::Migration
  def change
    create_table :gateway_routetables do |t|
      t.integer :gateway_id
      t.integer :route_table_id
      t.float :price
      t.datetime :created_at

      t.timestamps
    end
  end
end
