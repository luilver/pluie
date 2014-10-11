class ChangeBodyTypeInDeliveryReport < ActiveRecord::Migration
  def up
    change_column :action_smser_delivery_reports, :body, :text
  end
  def down
      change_column :action_smser_delivery_reports, :body, :string
  end
end
