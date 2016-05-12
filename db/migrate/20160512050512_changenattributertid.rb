class Changenattributertid < ActiveRecord::Migration
  def change
    rename_column :gateway_prefixtables, :route_table_id, :prefix_table_id
  end
end
