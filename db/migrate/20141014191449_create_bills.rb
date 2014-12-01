class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.integer :number_of_sms
      t.integer :finished_sms
      t.integer :accepted_numbers
      t.string :message_id
      t.belongs_to :user, index: true

      t.timestamps
    end
    add_index :bills, :message_id
  end
end
