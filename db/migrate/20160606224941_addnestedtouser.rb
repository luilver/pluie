class Addnestedtouser < ActiveRecord::Migration
  def change
    add_column :users, :nested_reseller, :integer, :default => 0
  end
end
