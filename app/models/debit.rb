class Debit < ActiveRecord::Base
  belongs_to :user
  validates :balance, presence: true
  validates :balance,  numericality: { greater_than: 0}
  validates :user, presence: true
  after_create :increase_user_debit

  def self.random
    Debit.all[rand Credit.count]
  end

  def to_s
    self.balance.to_s
  end

  def increase_user_debit
    self.user.debit += self.balance
    self.user.save
  end
end
