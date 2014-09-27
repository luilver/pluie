class CreateObservers < ActiveRecord::Migration
  def change
    create_table :observers do |t|
      t.string :number
      t.boolean :active

      t.timestamps
    end
  end
end
