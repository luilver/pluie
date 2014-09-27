require 'pluie_wisper'

route = Route.where(name: ActionSmserUtils::PLUIE_MSG).first
PluieWisper::MessagePublisher.subscribe(PluieWisper::ObserverListener.new(route, Rails.env.production?))

