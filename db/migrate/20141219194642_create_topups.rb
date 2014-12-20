class CreateTopups < ActiveRecord::Migration
  def change
    create_table :topups do |t|
      t.string :number
      t.integer :amount

      t.timestamps
    end
  end
end
