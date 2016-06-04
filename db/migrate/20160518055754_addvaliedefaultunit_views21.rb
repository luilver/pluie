class AddvaliedefaultunitViews21 < ActiveRecord::Migration
  def change
    User.all.each do |u|
      u.unit_views=false
      u.save
    end
  end
end
