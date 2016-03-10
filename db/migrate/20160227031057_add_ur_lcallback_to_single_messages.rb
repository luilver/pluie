class AddUrLcallbackToSingleMessages < ActiveRecord::Migration
  def change
    add_column :single_messages, :url_callback, :string
  end
end
