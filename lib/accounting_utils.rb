def billed_dlrs(scope = ActionSmser::DeliveryReport)
 scope.where(status: [ActionSmserUtils::UNDELIVERED_STATUS,
 	ActionSmserUtils::DELIVERED_STATUS, ActionSmserUtils::SENT_STATUS ])
end

def user_info(dlrs_scoped)
  User.all.map do |u|
    {
      user:  u,
      traffic: u.delivery_reports.merge(dlrs_scoped).group("gateway")
      .select("COUNT(id) as gc, gateway")
      .reduce(Hash.new(0)) {|memo, obj| memo[obj.gateway] = obj.gc; memo  }
    }
  end
end

def accounting_data(users_data)
  billing_data = users_data.map do |x|
    route_prices = []
    gateway_prices = []
    traffic = []
    x[:traffic].each_pair do |name, count|
      route = x[:user].routes.where(name: name).first
      route_prices << route.price rescue 0
      gateway_prices << route.gateway.price rescue 0
      traffic << count
    end
    {
      user: x[:user].username,
      billed: route_prices.zip(traffic).map { |p, c| p * c  }.sum,
      cost:  gateway_prices.zip(traffic).map { |p, c| p * c  }.sum
    }
  end

  billing_data.each { |data| data[:profit] = data[:billed] - data[:cost] }
  billing_data
end



