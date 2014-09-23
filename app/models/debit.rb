class Debit < ActiveRecord::Base
  belongs_to :user
  validates :balance, presence: true
  validates :balance,  numericality: {only_integer: true, greater_than: 0}
  validates :user, presence: true
end
