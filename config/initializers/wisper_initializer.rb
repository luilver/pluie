require 'pluie_wisper'

PluieWisper::MessagePublisher.subscribe(PluieWisper::ObserverListener.new( Rails.env.production?))
PluieWisper::MessagePublisher.subscribe(PluieWisper::Cashier.new)
