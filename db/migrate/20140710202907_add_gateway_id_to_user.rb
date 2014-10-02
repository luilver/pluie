class AddGatewayIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :gateway_id, :integer
  end
end
