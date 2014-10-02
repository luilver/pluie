class CreateBulkMessages < ActiveRecord::Migration
  def change
    create_table :bulk_messages do |t|
      t.text :message
      t.integer :list_id

      t.timestamps
    end
  end
end
