class CreateRoutesUsers < ActiveRecord::Migration
  def change
    create_table :routes_users, :id=>false do |t|
      t.belongs_to :route, :user
    end
  end
end
