class AddReceiverToSms < ActiveRecord::Migration
  def change
    add_column :sms, :receiver, :string
  end
end
