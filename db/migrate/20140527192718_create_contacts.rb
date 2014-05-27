class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.integer :gsm_number_id

      t.timestamps
    end
  end
end
