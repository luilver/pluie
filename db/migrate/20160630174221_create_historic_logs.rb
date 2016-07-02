class CreateHistoricLogs < ActiveRecord::Migration
  def change
    create_table :historic_logs do |t|
      t.string :action_name
      t.string :controller_name
      t.string :user_id

      t.timestamps
    end
  end
end
