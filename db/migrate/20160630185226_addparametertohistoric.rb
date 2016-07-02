class Addparametertohistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :parameter_req, :string
  end
end
