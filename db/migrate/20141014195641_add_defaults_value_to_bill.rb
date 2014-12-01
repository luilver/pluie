class AddDefaultsValueToBill < ActiveRecord::Migration
  def up
    remove_column :bills, :finished_sms
    remove_column :bills, :accepted_numbers

    add_column :bills, :finished_sms, :integer, default: 0
    add_column :bills, :accepted_numbers, :integer, default: 0
  end

  def down
    remove_column :bills, :finished_sms, :integer, default: 0
    remove_column :bills, :accepted_numbers, :integer, default: 0

    add_column :bills, :finished_sms, :integer
    add_column :bills, :accepted_numbers, :integer
  end
end
