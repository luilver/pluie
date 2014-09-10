# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Luilver
u = User.create([{ email: 'luilver@gmail.com', password: 'luilver8' },
                 { email: 'pepesenaris@gmail.com', password: 'pepe5678' }])

# Routesms
g = Gateway.new
g.name = 'routesms'
g.price = 0.0035
g.save
r = Route.new
r.price = 0.008
r.name = "Plata"
r.user = User.first
r.gateway = g
r.save
r = Route.new
r.price = 0.008
r.name = "Silver"
r.user = User.last
r.gateway = g
r.save

# Infobip
g = Gateway.new
g.name = 'infobip'
g.price = 0.0055
g.save
r = Route.new
r.price = 0.01
r.name = "Oro"
r.user = User.first
r.gateway = g
r.save
r = Route.new
r.price = 0.01
r.name = "Gold"
r.user = User.last
r.gateway = g
r.save
