require 'pluie_wisper'

PluieWisper::MessagePublisher.subscribe(PluieWisper::Cashier.new)
