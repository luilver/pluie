class CreateBulkMessagesGsmNumbers < ActiveRecord::Migration
  def change
    create_table :bulk_messages_gsm_numbers, :id => false do |t|
      t.belongs_to :bulk_message, :gsm_number
    end
  end
end
