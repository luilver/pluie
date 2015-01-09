require 'delayed_job'
require 'set'

class BulkMessage < Message
  has_and_belongs_to_many :lists
  validates :lists, presence: true

  def receivers
    set = Set.new
    self.lists.each do |list|
      set.merge list.receivers
    end
    set.to_a
  end

  def gsm_numbers
    set = Set.new
    self.lists.each do |list|
      set.merge list.gsm_numbers
    end
    set.to_a
  end

  def message_cost(&block)
    MessagePriceCalculator.new(BulkMsgReceiversCounter).calculate_price(self, &block)
  end
end
