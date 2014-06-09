class CreateBulkMessagesLists < ActiveRecord::Migration
  def change
    create_table :bulk_messages_lists do |t|
      t.belongs_to :bulk_message, :list
    end
  end
end
