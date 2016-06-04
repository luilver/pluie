class Cashier
  def self.charge(route_id, numbers_count, sms_parts,user,list_numbers)
    route = Route.find(route_id)
    #route_price = route.price
    cost=0
    user = user
    list_numbers.each do |number|
      price=route.get_price_country_code(number)
      cost = cost + ActionSmserUtils.sms_cost(1, price, sms_parts)
    end
    if cost > 0
      user.debits.create(balance: cost)
      Rails.logger.info "Charged #{cost} to #{user.username}. #{numbers_count} numbers accepted in #{route.gateway.name} gateway."
    else
      Rails.logger.info "Cost for sms in route #{route_id} is #{cost}"
    end
  end
end
