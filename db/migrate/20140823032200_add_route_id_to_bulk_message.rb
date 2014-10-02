class AddRouteIdToBulkMessage < ActiveRecord::Migration
  def change
    add_column :bulk_messages, :route_id, :integer
  end
end
