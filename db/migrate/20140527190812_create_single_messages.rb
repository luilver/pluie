class CreateSingleMessages < ActiveRecord::Migration
  def change
    create_table :single_messages do |t|
      t.text :message
      t.string :number

      t.timestamps
    end
  end
end
