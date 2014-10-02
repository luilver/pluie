class CreateContactsGsmNumbers < ActiveRecord::Migration
  def change
    create_table :contacts_gsm_numbers, :id => false do |t|
      t.belongs_to :contact, :gsm_number
    end
  end
end
