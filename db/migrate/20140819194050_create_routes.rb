class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.decimal :price
      t.integer :user_id
      t.integer :gateway_id

      t.timestamps
    end
  end
end
