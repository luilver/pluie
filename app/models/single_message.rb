class SingleMessage < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg
  belongs_to :route

  validates :number, presence: true
  validates :message, presence: true

  def receivers
    self.number.split(" ")
  end

  def deliver(dlr_method=nil)
    sms = SimpleSms.multiple_receivers(receivers, self.message, self.user.id, self.route.id, dlr_method)
    sms.deliver
  end

end
