class Changenameprefixtable < ActiveRecord::Migration
  def change
    rename_table :prefix_table, :prefix_tables
  end
end
