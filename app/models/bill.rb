class Bill < ActiveRecord::Base
  belongs_to :user

  def close_pending_sms(numbers_count)
    self.finished_sms += 1
    self.accepted_numbers += numbers_count
    self.save
  end

  def closed?
    self.number_of_sms == self.finished_sms
  end
end
