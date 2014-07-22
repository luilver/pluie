class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.belongs_to :gateway, index: true
      t.belongs_to :user, index: true
      t.belongs_to :msg, polymorphic: true, index: true

      t.timestamps
    end
  end
end
