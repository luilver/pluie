class AddunitViewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unit_view, :boolean
  end
end
