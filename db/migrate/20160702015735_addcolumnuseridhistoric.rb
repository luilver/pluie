class Addcolumnuseridhistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :user_id, :integer, :default => 0
  end
end
