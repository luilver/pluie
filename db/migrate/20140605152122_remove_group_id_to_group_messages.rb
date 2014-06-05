class RemoveGroupIdToGroupMessages < ActiveRecord::Migration
  def change
    remove_column :group_messages, :group_id
  end
end
