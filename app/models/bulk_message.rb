require 'delayed_job'

class BulkMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :route
  has_and_belongs_to_many :lists
  #has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg

  validates :message, presence: true
  validates :lists, presence: true

  def receivers
    self.gsm_numbers.map {|gsm| gsm.number}
  end

  def deliver(dlr_method=nil)
    sms = SimpleSms.multiple_receivers(receivers, self.message, self.user.id, self.route.id, dlr_method)
    Delayed::Job.enqueue(sms)
  end

  def gsm_numbers
    list = []
    self.lists.each do |l|
      l.gsm_numbers.each {
        |n| list << n if not lists.include?(n)
      }
    end
    list
  end

end
