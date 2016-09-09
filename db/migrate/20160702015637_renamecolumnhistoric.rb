class Renamecolumnhistoric < ActiveRecord::Migration
  def change
    rename_column :historic_logs, :user_id, :user_all_string
  end
end
