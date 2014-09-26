require 'pluie_wisper'

PUBLISHER = PluieWisper::MessagePublisher.new
route = Route.where(name: 'Pluie')
PUBLISHER.subscribe(PluieWisper::ObserverListener.new(route, Rails.env.production?))
