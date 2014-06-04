class RemoveGsmNumberToContacts < ActiveRecord::Migration
  def change
    remove_column :contacts, :gsm_number_id
  end
end
