require_relative 'smpp_gateway'

module SmppTools
  class SimpleSmppGateway < SmppGateway

    register_subclass "infobip"
    register_subclass "nexmo"

    def initialize(name, logger=nil)
      super(name, logger)
      @queue = SmppTools.get_producer(name).queue
      #Se asume que los mensajes se obtendran a traves de una EM::Queue
      #En particular, la cola creada en la instancia de SimpleProducer asociada
      #al gateway(name) dado
    end

    def process_next_item
      @queue.pop(&method(:fetch_message))
    end

    def fetch_message(q_sms)
      begin
        send_message(q_sms)
        process_next_item if @queue.num_waiting < 1
      rescue Exception => e
        logger.error e.message
      end
    end

    def to_s
      "#{@name} gateway with queue #{@queue}"
    end

    ##############TODO##############
    #Comprobar que al tener dos instancias de smpp gateway, con sendas EM::Queue
    #lleguen los mensajes a los gateways correctos,...
    #me parece que las colas solo estan poniendo los callbacks en el ciclo de eventos
    #de EM, y que se puede perder, la nocion de separar las conexiones usando instancias distintas
    #y que en su lugar hay tener todas las conexiones en el mismo lugar,
    #y enviar un sms usando la conexion adecuada
    ###############TODO##############

  end
end
