class DropGroupMessagesGroups < ActiveRecord::Migration
  def change
    drop_table :group_messages_groups
  end
end
