class AddTokenNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :token_number, :string
  end
end
