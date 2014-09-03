require 'credit_validator'

class SingleMessage < ActiveRecord::Base
  include ActiveModel::Validations
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg
  belongs_to :route

  validates :number, presence: true
  validates :message, presence: true
  validates_with Validations::CreditValidator

  before_save :related_numbers

  def receivers
    self.number.split(" ")
  end

  def deliver(dlr_method=nil)
    sms = SimpleSms.multiple_receivers(receivers, self.message, self.user.id, self.route.id, dlr_method)
    sms.deliver
  end

  private
    def related_numbers
      self.number.split.each { |num| n = GsmNumber.find_by_number(num) ||
                                          GsmNumber.create(:number => num);
                                          self.gsm_numbers << n if not self.gsm_numbers.include?(n)
      }
    end

end
