class ChangeDebitLimitFromUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :debit_limit, :max_debt
    end
  end
end
