class AddCreditLimitToUser < ActiveRecord::Migration
  def change
    add_column :users, :credit_limit, :decimal, default: -10
  end
end
