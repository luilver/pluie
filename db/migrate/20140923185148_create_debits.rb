class CreateDebits < ActiveRecord::Migration
  def change
    create_table :debits do |t|
      t.belongs_to :user, index: true
      t.decimal :balance

      t.timestamps
    end
  end
end
