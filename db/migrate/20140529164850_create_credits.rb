class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.decimal :balance

      t.timestamps
    end
  end
end
