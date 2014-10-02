class BulkMessageUserId < ActiveRecord::Migration
  def change
    add_column :bulk_messages, :user_id, :integer
  end
end
