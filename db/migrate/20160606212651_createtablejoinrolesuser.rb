class Createtablejoinrolesuser < ActiveRecord::Migration
  def change
    create_table :roles_users, :id =>false do |t|
      t.belongs_to :role, :user
    end
  end
end
