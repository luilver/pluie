class Fullpathstohistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :full_path, :string
  end
end
