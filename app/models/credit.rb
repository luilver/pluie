class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner
  validates :balance, presence: true
  validates :balance,  numericality: { greater_than: 0}
  validates :user, presence: true
  after_create :increase_user_credit

  def save_owner
    self.user.save
  end

  def self.random
    Credit.all[rand Credit.count]
  end

  def to_s
    self.balance.to_s
  end

  def increase_user_credit
    self.user.credit += self.balance
    self.user.save
  end
end
