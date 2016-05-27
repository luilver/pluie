class AddpriceToBill < ActiveRecord::Migration
  def change
    add_column  :bills, :price_numbers_accepted, :float, :default => 0
  end
end
