class AddConfirmTokenNumberToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirm_token_number, :datetime
  end
end
