class Changetypeuseridhistoric < ActiveRecord::Migration
  def change
    change_column :historic_logs, :user_id, :integer
  end
end
