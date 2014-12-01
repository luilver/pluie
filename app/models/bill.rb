class Bill < ActiveRecord::Base
  belongs_to :user

  def update_and_charge_if_ended(numbers, route_id, sms_parts)
    add_numbers(numbers)
    charge_bill(route_id, sms_parts) if closed?
  end

  def add_numbers(succesfull_numbers)
    self.finished_sms += 1
    self.accepted_numbers += succesfull_numbers
    self.save
  end

  def charge_bill(route_id, sms_parts)
    route_price = Route.find(route_id).price
    cost = ActionSmserUtils.sms_cost(self.accepted_numbers, route_price, sms_parts)
    self.user.bill_sms(cost) if cost > 0
    Rails.logger.info "Charged #{cost} to #{self.user.username} for msg #{self.message_id}. #{self.accepted_numbers} numbers accepted in Gateway."
  end

  private
    def closed?
      self.number_of_sms == self.finished_sms
    end
end
