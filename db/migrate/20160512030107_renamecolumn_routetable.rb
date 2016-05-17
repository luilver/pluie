class RenamecolumnRoutetable < ActiveRecord::Migration
  def change
    rename_column :gateway_routetables, :price, :price_system
  end
end
