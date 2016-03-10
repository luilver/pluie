class AddMovilnumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :movil_number, :string
  end
end
