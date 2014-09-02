require 'delayed_job'

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

  def deliver(dlr_method=nil)
    numbers = receivers.to_a
    size = [(numbers.size * ActionSmser.delivery_options[:numbers_from_bulk]).to_i, ActionSmser.delivery_options[:min_sms_numbers_count]].max
    batches = numbers.each_slice(size).to_a
    batches.each_with_index do |nums, index|
      sms = SimpleSms.multiple_receivers(nums, self.message, self.user.id, self.route.id, dlr_method)
      Delayed::Job.enqueue(sms, :priority => bulk_sms_priority(index), :queue => bulk_sms_queue)
    end
  end

end
