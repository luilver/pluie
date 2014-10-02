class CreateApiSettings < ActiveRecord::Migration
  def change
    create_table :api_settings do |t|
      t.string :api_key
      t.string :api_secret
      t.integer :user_id

      t.timestamps
    end
  end
end
