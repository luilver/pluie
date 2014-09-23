class Debit < ActiveRecord::Base
  belongs_to :user
  validates :balance, presence: true
  validates :balance,  numericality: { greater_than: 0}
  validates :user, presence: true

  def self.random
    Debit.all[rand Credit.count]
  end
end
