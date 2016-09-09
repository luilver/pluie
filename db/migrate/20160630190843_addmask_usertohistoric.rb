class AddmaskUsertohistoric < ActiveRecord::Migration
  def change
    add_column :historic_logs, :mask_user_active, :integer, :default => 0
  end
end
