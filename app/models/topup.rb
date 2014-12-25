class Topup < ActiveRecord::Base
  belongs_to :user
  validates :number, presence: true, gsm: true

  def to_s
    "number:#{number} amount:#{amount}"
  end
end
