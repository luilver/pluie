class AddlowaccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :low_account, :string
  end
end
