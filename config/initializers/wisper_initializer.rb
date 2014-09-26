require 'pluie_wisper'

route = Route.where(name: 'Pluie').first
PluieWisper::MessagePublisher.subscribe(PluieWisper::ObserverListener.new(route, Rails.env.production?))

