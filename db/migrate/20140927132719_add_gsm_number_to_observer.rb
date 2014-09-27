class AddGsmNumberToObserver < ActiveRecord::Migration
  def change
    add_reference :observers, :gsm_number, index: true
  end
end
