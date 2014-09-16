class ChangeDefaultCreditLimit < ActiveRecord::Migration
  def change
    remove_column :users, :credit_limit
    add_column :users, :credit_limit, :decimal, default: 0
  end
end
