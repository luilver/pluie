class CreateTableRoutes < ActiveRecord::Migration
  def change
    create_table :table_routes do |t|
      t.string :name_route
      t.float :price_system
      t.float :price_cost
      t.string :country_code
      t.string :country

      t.timestamps
    end
  end
end
