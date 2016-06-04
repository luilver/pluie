class RenameTableRouteTable < ActiveRecord::Migration
  def change
    rename_table :route_tables, :prefix_table
  end
end
