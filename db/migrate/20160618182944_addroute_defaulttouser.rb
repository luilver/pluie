class AddrouteDefaulttouser < ActiveRecord::Migration
  def change
    add_column :users, :route_default, :integer, :default => 0
  end
end
