class CreateGateways < ActiveRecord::Migration
  def change
    create_table :gateways do |t|
      t.string :name
      t.decimal :price

      t.timestamps
    end
  end
end
