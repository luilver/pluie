class RemoveDeliveryReports < ActiveRecord::Migration
  def change
    drop_table :delivery_reports
  end
end
