class SingleMessageUserId < ActiveRecord::Migration
  def change
    add_column :single_messages, :user_id, :integer
  end
end
