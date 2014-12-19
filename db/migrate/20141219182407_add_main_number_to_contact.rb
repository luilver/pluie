class AddMainNumberToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :gsm_number_id, :integer
  end
end
