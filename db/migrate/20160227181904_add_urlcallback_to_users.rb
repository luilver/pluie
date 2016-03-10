class AddUrlcallbackToUsers < ActiveRecord::Migration
  def change
    add_column :users, :url_callback, :string
  end
end
