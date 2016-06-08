class Bill < ActiveRecord::Base
  belongs_to :user

  def close_pending_sms(numbers_count,sms,number_list)
    self.finished_sms += 1
    self.accepted_numbers += numbers_count
    price=Route.find(sms.route_id).get_price_country_code(number_list.first)
    self.price_numbers_accepted= self.price_numbers_accepted + price
    self.save
  end

  def closed?
    self.number_of_sms == self.finished_sms
  end
end
