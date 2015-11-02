class SingleMessage < Message
  has_and_belongs_to_many :gsm_numbers
  validates :number, presence: true, multi_gsm: true
  before_save :related_numbers
  before_validation :remove_extra_whitespaces

  def receivers
    self.gsm_numbers.map { |gsm| gsm.number }
  end

  def valid_gsm_numbers_from_field
    self.number.split(/[[:blank:]]/).select { |num| /535[0-9]{7}/ =~ num }
  end

  def valid_gsm_numberAPI(numbers_message)
    numbers_message.select{|k| /535[0-9]{7}/=~ k.to_s}.map{|num| n = GsmNumber.find_or_create_by(:number=> num);
                                                      self.gsm_numbers << n if not self.gsm_numbers.include?(n)
    }
    self.number =self.gsm_numbers.map{|k| k.number}.join(" ")
  end

  def message_cost(&block)
    MessagePriceCalculator.new(SingleMsgReceiversCounter).calculate_price(self, &block)
  end

  private
    def related_numbers
      self.gsm_numbers.delete_all if self.gsm_numbers.any?
      valid_gsm_numbers_from_field.each { |num| n = GsmNumber.find_or_create_by(:number => num);
                                          self.gsm_numbers << n if not self.gsm_numbers.include?(n)
      }
    end

    def remove_extra_whitespaces
      if number
        number.strip!
        number.gsub!(/[[:blank:]]+/, " ")
      end
    end
end

