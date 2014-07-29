class BulkMessage < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :gsm_numbers
  has_many :sms, as: :msg

  def receivers
    self.gsm_numbers.map {|gsm| gsm.number}
  end

end
