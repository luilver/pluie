require 'pluie_wisper'

PluieWisper::MessagePublisher.subscribe(PluieWisper::ObserverListener.new( Rails.env.production?))

