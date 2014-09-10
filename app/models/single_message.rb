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

  def deliver
    sms = SimpleSms.multiple_receivers(receivers, self)
    sms.deliver
  end

  def self.random
    SingleMessage.all[rand BulkMessage.all.size]
  end

  private
    def related_numbers
      self.number.split.each { |num| n = GsmNumber.find_by_number(num) ||
                                          GsmNumber.create(:number => num);
                                          self.gsm_numbers << n if not self.gsm_numbers.include?(n)
      }
    end

end
