class CreateGroupMessages < ActiveRecord::Migration
  def change
    create_table :group_messages do |t|
      t.integer :group_id
      t.text :message

      t.timestamps
    end
  end
end
