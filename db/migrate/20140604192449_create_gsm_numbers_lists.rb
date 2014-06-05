class CreateGsmNumbersLists < ActiveRecord::Migration
  def change
    create_table :gsm_numbers_lists, :id => false do |t|
      t.belongs_to :list, :gsm_number
    end
  end
end
