class RemoveGatewayIdToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :gateway_id
  end
end
