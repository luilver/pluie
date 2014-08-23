class SingleMessage < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg
  belongs_to :route

  def receivers
    self.number.split(" ")
  end

end
