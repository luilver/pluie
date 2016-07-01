class Addmethodhttptohistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :method_http, :string
  end
end
