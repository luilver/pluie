class GroupMessageUserId < ActiveRecord::Migration
  def change
    add_column :group_messages, :user_id, :integer
  end
end
