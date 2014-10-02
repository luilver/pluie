class RecreateGroupMessagesGroups < ActiveRecord::Migration
  def change
    create_table :group_messages_groups, :id => false do |t|
      t.belongs_to :group_message, :group
    end
  end
end
