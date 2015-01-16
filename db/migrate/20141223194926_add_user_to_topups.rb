class AddUserToTopups < ActiveRecord::Migration
  def change
    add_column :topups, :user_id, :integer
  end
end
