class ChangeCreditLimitFromUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :credit_limit, :debit_limit
    end
  end
end
