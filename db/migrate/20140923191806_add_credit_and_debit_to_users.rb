class AddCreditAndDebitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :credit, :decimal, default: 0
    add_column :users, :debit, :decimal, default: 0
  end
end
