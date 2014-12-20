class AddPluieIdToActionSmserDeliveryReport < ActiveRecord::Migration
  def change
    add_column :action_smser_delivery_reports, :pluie_id, :string
    add_index :action_smser_delivery_reports, :pluie_id
  end
end
