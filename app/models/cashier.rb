class Cashier
  def self.charge(route_id, numbers_count, sms_parts,user,price_accepted_number)
    route = Route.find(route_id)
    #route_price = route.price
    cost=0
    user = user
    cost=price_accepted_number*sms_parts
    if cost > 0
      user.debits.create(balance: cost)
      Rails.logger.info "Charged #{cost} to #{user.username}. #{numbers_count} numbers accepted in #{route.gateway.name} gateway."
    else
      Rails.logger.info "Cost for sms in route #{route_id} is #{cost}"
    end
  end
end
