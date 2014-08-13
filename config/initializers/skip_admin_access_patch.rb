require 'action_smser/delivery_reports_controller'

ActionSmser::DeliveryReportsController.class_eval do
  def admin_access_only()
    true
  end
end
