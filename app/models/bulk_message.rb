require 'credit_validator'
require 'delayed_job'
require 'set'

class BulkMessage < ActiveRecord::Base
  include ActiveModel::Validations
  belongs_to :user
  belongs_to :route
  has_and_belongs_to_many :lists
  #has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg

  validates :message, presence: true
  validates :lists, presence: true
  validates_with Validations::CreditValidator

  def receivers
    self.gsm_numbers.map {|gsm| gsm.number}
  end

  def deliver
    begin
    dlr_method = self.route.gateway.name
    numbers = receivers.to_a
    size = [(numbers.size * ActionSmser.delivery_options[:numbers_from_bulk]).to_i, ActionSmser.delivery_options[:min_numbers_in_sms]].max
    batches = numbers.each_slice(size).to_a
    batches.each_with_index do |nums, index|
      sms = SimpleSms.multiple_receivers(nums, self)
      Delayed::Job.enqueue(sms, :priority => bulk_sms_priority(index), :queue => bulk_sms_queue)
    end
    rescue StandardError => e
      File.open('/tmp/delayed_job.log', "a+") do |file|
        file.write "Dentro del rescue \n"
      end
    end
    File.open('/tmp/delayed_job.log', "a+") do |file|
      file.write "Fuera del rescue \n"
    end
  end

  def gsm_numbers
    set = Set.new
    self.lists.each do |list|
      set.merge list.gsm_numbers
    end
    set.to_a
  end

  def self.random
    BulkMessage.all[rand BulkMessage.count]
  end

  def gsm_numbers_count
    self.lists.inject(0) {|tmp, l| tmp + l.gsm_numbers.count}
  end
end
