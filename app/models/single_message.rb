class SingleMessage < Message
  has_and_belongs_to_many :gsm_numbers
  validates :number, presence: true
  before_save :related_numbers

  def receivers
    self.number.split(" ")
  end

  def gsm_numbers_count
    receivers.size
  end

  def deliver
    bill = Bill.create(number_of_sms: 1, message_id: self.pluie_message_id, user: self.user)
    sms = SimpleSms.multiple_receivers(receivers, self, bill.id)
    sms.deliver
    super()
  end

  private
    def related_numbers
      self.gsm_numbers.delete_all if self.gsm_numbers.any?
      self.number.split.each { |num| n = GsmNumber.find_or_create_by(:number => num);
                                          self.gsm_numbers << n if not self.gsm_numbers.include?(n)
      }
    end
end
