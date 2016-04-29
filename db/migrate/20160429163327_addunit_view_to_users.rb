class AddunitViewToUsers < ActiveRecord::Migration
  def change
    add_column :users, :unit_views, :boolean
  end

  def down
    remove_column :users, :unit_views
  end
end
