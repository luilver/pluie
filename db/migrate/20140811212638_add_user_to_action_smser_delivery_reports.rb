class AddUserToActionSmserDeliveryReports < ActiveRecord::Migration
  def change
    add_reference :action_smser_delivery_reports, :user, index: true
  end
end
