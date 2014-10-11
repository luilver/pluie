class AddOpenedToList < ActiveRecord::Migration
  def change
    add_column :lists, :opened, :boolean, default: true
  end
end
