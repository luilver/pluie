class Parametersnotcomuntohistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :parameters_not_comun, :text
  end
end
