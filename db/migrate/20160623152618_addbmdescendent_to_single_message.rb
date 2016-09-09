class AddbmdescendentToSingleMessage < ActiveRecord::Migration
  def change
    add_column :single_messages, :bm_descendent, :integer, :default => 0
  end
end
