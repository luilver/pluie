class CreateGsmNumbersSingleMessages < ActiveRecord::Migration
  def change
    create_table :gsm_numbers_single_messages, :id => false do |t|
      t.belongs_to :single_message, :gsm_number
    end
  end
end
