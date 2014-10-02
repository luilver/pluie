class CreateContactsGroups < ActiveRecord::Migration
  def change
    create_table :contacts_groups, :id => false do |t|
      t.belongs_to :group, :contact
    end
  end
end
