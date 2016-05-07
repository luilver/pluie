class CreateRouteTables < ActiveRecord::Migration
  def change
    create_table :route_tables do |t|
      t.string :country_code
      t.string :country

      t.timestamps
    end
  end
end
