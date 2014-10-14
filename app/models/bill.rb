class Bill < ActiveRecord::Base
  belongs_to :user

  def charge_numbers(route_id, succesfull_numbers, sms_parts)
    self.finished_sms += 1
    self.accepted_numbers += succesfull_numbers
    if self.number_of_sms == self.finished_sms
      route_price = Route.find(route_id).price
      cost = ActionSmserUtils.sms_cost(self.accepted_numbers, route_price, sms_parts)
      self.user.bill_sms(cost) if cost > 0
      Rails.logger.info "Charged #{cost} to #{self.user.username} for msg #{self.message_id}. #{self.accepted_numbers} numbers accepted in Gateway."
    end
    self.save
  end
end
