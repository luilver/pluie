class BulkMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :route
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg

  validates :message, presence: true

  def receivers
    self.gsm_numbers.map {|gsm| gsm.number}
  end

end
