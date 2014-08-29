require 'delayed_job'
require 'lists_validator'

class BulkMessage < ActiveRecord::Base
  include ActiveModel::Validations
  belongs_to :user
  belongs_to :route
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg

  validates :message, presence: true
  validates_with Validations::ListsValidator

  def receivers
    self.gsm_numbers.map {|gsm| gsm.number}
  end

  def deliver(dlr_method=nil)
    sms = SimpleSms.multiple_receivers(receivers, self.message, self.user.id, self.route.id, dlr_method)
    Delayed::Job.enqueue(sms)
  end

end
