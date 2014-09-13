# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Luilver
users = User.create([{ email: 'luilver@gmail.com', password: 'luilver8' },
                 { email: 'pepesenaris@gmail.com', password: 'pepe5678' },
                 { email: 'admin@openbgs.com', password: 'gbsc1234', admin: true}])

gateways = Gateway.create([{name: 'routesms', price: 0.0035},
                           {name: 'infobip', price: 0.0055},
                           {name: 'nexmo', price: 0.034}])

route_data = [{name: 'Silver',price: 0.008, gateway: gateways.find { |g| g.name == 'routesms'}},
              {name: 'Gold', price: 0.01, gateway: gateways.find { |g| g.name == 'infobip'}},
              {name: 'Diamond', price: 0.10, gateway: gateways.find { |g| g.name == 'nexmo'}}
            ]

users.each do |u|
  Route.create(route_data) do |r|
    r.user = u
  end
end
