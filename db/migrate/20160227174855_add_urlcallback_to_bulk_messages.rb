class AddUrlcallbackToBulkMessages < ActiveRecord::Migration
  def change
    add_column :bulk_messages, :url_callback, :string
  end
end
