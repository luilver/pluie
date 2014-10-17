require 'credit_validator'

class SingleMessage < ActiveRecord::Base
  include ActiveModel::Validations
  include Gsmeable
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  belongs_to :route

  validates :number, presence: true
  validates :message, presence: true
  validates_with Validations::CreditValidator

  before_save :related_numbers

  def receivers
    self.number.split(" ")
  end

  def gsm_numbers_count
    receivers.size
  end

  def deliver
    sms = SimpleSms.multiple_receivers(receivers, self)
    sms.deliver
  end

  def self.random
    SingleMessage.all[rand SingleMessage.count]
  end

  private
    def related_numbers
      self.number.split.each { |num| n = GsmNumber.find_or_create_by(:number => num);
                                          self.gsm_numbers << n if not self.gsm_numbers.include?(n)
      }
    end

end
