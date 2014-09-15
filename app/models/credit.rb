class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner

  def save_owner
    self.user.save
  end

  def self.random
    Credit.all[rand Credit.count]
  end
end
