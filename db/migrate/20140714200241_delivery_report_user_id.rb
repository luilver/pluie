class DeliveryReportUserId < ActiveRecord::Migration
  def change
    add_column :delivery_reports, :user_id, :integer
  end
end
