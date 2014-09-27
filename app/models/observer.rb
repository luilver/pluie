class Observer < ActiveRecord::Base
  belongs_to :gsm_number
  validates :number, :presence => true
  before_save :relate_number

  private
    def relate_number
      self.gsm_number = GsmNumber.find_or_create_by(number: self.number)
    end
end
