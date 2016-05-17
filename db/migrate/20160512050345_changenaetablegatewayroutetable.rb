class Changenaetablegatewayroutetable < ActiveRecord::Migration
  def change
    rename_table :gateway_routetables, :gateway_prefixtables
  end
end
