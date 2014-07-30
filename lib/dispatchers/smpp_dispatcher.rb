require 'smpp_tools/smpp_tools'
require_relative 'base'

module DeliveryMethods
  class SmppDispatcher < DeliveryMethods::Base

    register_subclass "infobip"
    #register_subclass "nexmo" #Uncomment once the nexmo config is setup

    def initialize(user)
      super
    end

    def send_sms(sms_list)

      gateway_name = sms_list.first.gateway.name
      producer = SmppTools.get_producer(gateway_name) #para  enviar(encolar) los mensajes
      smpp_gateway = SmppTools.get_smpp_gateway(gateway_name) #debe conectarse, una vez que este corriendo eventmachine
      SmppTools.connect_to_server(smpp_gateway)

      sms_list.each do |sms|
        producer << sms
      end
    end

  end
end


# producer = SmppTools.get_producer(gtw_name) #para  enviar(encolar) los mensajes

# gateway = SmppTools.get_smpp_gateway(gtw_name) #debe conectarse, una vez que este corriendo eventmachine

# sleep 2
# puts "# gtw_name is #{gtw_name}"
# puts "# producer name is #{producer.name}"
# puts "# gateway name is #{gateway.name}"

# puts "# gateway is #{gateway}"
# SmppTools.connect_to_server(gateway)
