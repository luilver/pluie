class AddRouteIdToSingleMessage < ActiveRecord::Migration
  def change
    add_column :single_messages, :route_id, :integer
  end
end
