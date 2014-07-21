#Cada instancia de SmppGateway esta asociada a un Gateway o proveedor que envia mensajes
#(nexmo, infobip, etc) usando una api Smpp.  El nombre(@name) de un SmppGateway debe coincidir
#con el del Gateway asociado a él.

module SmppTools
  class SmppGateway

    attr_reader :name

    def initialize(name)
      @name = name
    end

  end
end
