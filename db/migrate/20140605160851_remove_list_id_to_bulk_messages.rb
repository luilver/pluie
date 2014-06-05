class RemoveListIdToBulkMessages < ActiveRecord::Migration
  def change
    remove_column :bulk_messages, :list_id
  end
end
