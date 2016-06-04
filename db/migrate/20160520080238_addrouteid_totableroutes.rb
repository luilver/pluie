class AddrouteidTotableroutes < ActiveRecord::Migration
  def change
    add_column :table_routes, :route_id, :integer, :default=>1
  end
end
