class CreateGsmNumbers < ActiveRecord::Migration
  def change
    create_table :gsm_numbers do |t|
      t.string :number

      t.timestamps
    end
  end
end
