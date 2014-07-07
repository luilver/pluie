require 'dispatchers/nexmo_sp'

module DeliveryMethods

  module ClassMethods

  end

  module InstanceMethods


    def set_sms_dispatcher
      #crea la variable en el controller, a traves de la cual se enviaran los mensajes
      #la idea seria, ejecutar este metodo en cada controller que envie mensajes y luego
      #con los metodos de instancia del modulo SmsApi, se envian los mensajes
      #
      #ahora solo esta la implementacion de Nexmo,...
      #en general, segun la ruta o proveedor que escoja el usuario, se instancia
      #la  clase correspondiente.
      @dispatcher =  NexmoSp.new
    end

    def send_message(single_msg)
      @dispatcher.send_message(single_msg)
    end

    def send_bulk(bulk_msg)
      @dispatcher.send_bulk(bulk_msg)
    end

    def get_balance
      @dispatcher.get_balance
    end

  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
