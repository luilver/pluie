class DropSms < ActiveRecord::Migration
  def change
    drop_table :sms
  end
end
