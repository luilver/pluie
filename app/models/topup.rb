class Topup < ActiveRecord::Base
  belongs_to :user
  validates :number, presence: true, gsm: true
end
