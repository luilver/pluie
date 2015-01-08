class RemoveMaxDebtFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :max_debt, :decimal
  end
end
