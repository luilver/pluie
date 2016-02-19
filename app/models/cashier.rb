class Cashier
  def self.charge(route_id, numbers_count, sms_parts,user)
    route = Route.find(route_id)
    route_price = route.price
    user = user
    cost = ActionSmserUtils.sms_cost(numbers_count, route_price, sms_parts)
    if cost > 0
      user.debits.create(balance: cost)
      Rails.logger.info "Charged #{cost} to #{user.username}. #{numbers_count} numbers accepted in #{route.gateway.name} gateway."
    else
      Rails.logger.info "Cost for sms in route #{route_id} is #{cost}"
    end
  end
end
