class AddSystemRouteToRoute < ActiveRecord::Migration
  def change
    add_column :routes, :system_route, :boolean, default: false
  end
end
