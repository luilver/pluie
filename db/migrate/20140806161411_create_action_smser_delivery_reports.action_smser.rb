# This migration comes from action_smser (originally 20120102215215)
class CreateActionSmserDeliveryReports < ActiveRecord::Migration
  def change
    create_table :action_smser_delivery_reports do |t|
      t.string :msg_id
      t.string :status
      t.datetime :status_updated_at
      t.string :sms_type
      t.text   :log

      t.string :to
      t.string :from
      t.string :body

      t.string :gateway
      t.integer :re_delivery_of_delivery_report_id
      t.boolean :re_delivered

      t.timestamps
    end

    add_index "action_smser_delivery_reports", :msg_id
  end
end
