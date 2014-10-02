# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Luilver
users = User.create([{ email: 'luilver@gmail.com', password: 'luilver8', confirmed_at: Time.current },
                 { email: 'pepesenaris@gmail.com', password: 'pepe5678', confirmed_at: Time.current },
                 { email: 'admin@openbgs.com', password: 'gbsc1234', admin: true, confirmed_at: Time.current }])

gateways = Gateway.create([{name: 'routesms', price: 0.0035},
                           {name: 'routesms1', price: 0.0028},
                           {name: 'infobip', price: 0.0055},
                           {name: 'nexmo', price: 0.034}])

route_data = [
             #{name: 'Diamond', price: 0.07, gateway: gateways.find { |g| g.name == 'nexmo'}},
              {name: 'Bronce', price: 0.008, gateway: gateways.find { |g| g.name == 'routesms1'}},
              {name: 'Silver', price: 0.009, gateway: gateways.find { |g| g.name == 'routesms'}},
              {name: 'Gold', price: 0.01, gateway: gateways.find { |g| g.name == 'infobip'}}
             ]

users.each do |u|
  data = route_data.dup.map { |rd| rd.merge({ user: u }) }
  Route.create(data)
end

pluie = User.create({email: 'pluie@openbgs.com', password: 'pluieobserver1', max_debt: 100000, confirmed_at: Time.current })
cheap = gateways.min_by {|g| g.price }
Route.create({name: 'Pluie', price: cheap.price, gateway: cheap, user: pluie, system_route: true})
