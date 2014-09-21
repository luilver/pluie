class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner
  validates :balance,  numericality: {only_integer: true, greater_than: 0}
  validates :user, presence: true

  def save_owner
    self.user.save
  end

  def self.random
    Credit.all[rand Credit.count]
  end
end
