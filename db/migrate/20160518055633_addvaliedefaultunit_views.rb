class AddvaliedefaultunitViews < ActiveRecord::Migration
  def change
    change_column :users, :unit_views, :boolean, :default => false
  end
end
