class Credit < ActiveRecord::Base
  belongs_to :user
  before_save :save_owner
  validates :balance, presence: true
  validates :balance,  numericality: { greater_than: 0}
  validates :user, presence: true
  after_create :add_credit_to_user

  def save_owner
    self.user.save
  end

  def self.random
    Credit.all[rand Credit.count]
  end

  def to_s
    self.balance.to_s
  end

  private
    def add_credit_to_user
      self.user.credit += self.balance
      self.user.save
    end
end
