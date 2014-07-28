#Cada instancia de SmppGateway esta asociada a un Gateway o proveedor que envia mensajes
#(nexmo, infobip, etc) usando una api Smpp.  El nombre(@name) de un SmppGateway debe coincidir
#con el del Gateway asociado a él.
require 'smpp'
require 'logger'


module SmppTools

  WAIT_TIME = 5
  MAX_SIZE = 160

  class SmppGateway

    attr_reader :name
    attr_accessor :single_connection
    #true if only one connection to a smpp server is stablished in this process, false otherwise
    #if two or more connections can be stablished in the same process, then none of them
    #can terminate the EM event loop in order to mantain the remaining connections alive.


    def initialize(name, logger=nil)
      @name = name
      @tx = nil # Smpp::Transceiver
      Smpp::Base.logger =  logger || Logger.new(STDOUT)
      @server_bound = false
      @single_connection = false
    end

    def send_message(sms)
      id, receiver, text, sender = get_fields(sms)
      smpp_dispatcher = choose_method(text)

      if user_has_credit_for(sms)
        smpp_dispatcher.call(id, sender, receiver, text)
        sms.charge_to_user
      else
        logger.info "#{user.email} has not enough credit. Failed sending sms #{sms.id}"
      end

    end

    def start_loop(config)

      loop do
        EM::run do

          setup_smpp_connection(config)

          schedule_sms_sending
        end

        logger.info "Disconnected. Reconnecting in #{WAIT_TIME} seconds"
        sleep(WAIT_TIME)
      end
    end

    def connect(config)
      if EM.reactor_running?
        setup_smpp_connection(config)
      else
        logger.info "EM reactor loop is not running. Can not connect to #{config[:host]}"
      end
    end

    ############### Smpp callback methods
    def delivery_report_received(transceiver, pdu)
      logger.info "Delegate: delivery_report_received: ref #{pdu.msg_reference} stat #{pdu.stat}"
    end

    def message_accepted(transceiver, mt_message_id, pdu)
      logger.info "Delegate: message_accepted: id #{mt_message_id} smsc ref id: #{pdu.message_id}"
    end

    def message_rejected(transceiver, mt_message_id, pdu)
      logger.info "Delegate: message_rejected: id #{mt_message_id} smsc ref id: #{pdu.message_id}"
    end

    def bound(transceiver)
      @server_bound = true
      process_next_item()

      logger.info "Delegate: transceiver bound"
    end

    def unbound(transceiver)
      @server_bound = false
      logger.info "Delegate: transceiver unbound"
      EventMachine::stop_event_loop if @single_connection
    end
    ####################

    protected
      def process_next_item
        #get the next message from a queue or some other mechanism
      end

      def setup_smpp_connection(config)
        @tx = EM::connect(
            config[:host], config[:port],
            Smpp::Transceiver,
            config,
            self   # Receive callbacks on Delivery Reports and other events
            )
      end

      def schedule_sms_sending
        #Use this to implement a different strategy for sending messages
        #For example, to send 5 sms/second, sms can be stored in a
        #queue and a periodic timer can be set to retrieve them in batches.
      end

    private

      def logger
        Smpp::Base.logger
      end

      def get_fields(sms)
        #the message does not have a sender, but smpp requires one. The empty string works just fine
        return sms.id, sms.receiver, sms.text, ""
      end

      def large_text(txt)
        return txt.size > MAX_SIZE
      end

      def choose_method(text)
        if large_text(text)
          lambda { | *args | @tx.send_concat_mt(*args) }
        else
          lambda { | *args | @tx.send_mt(*args) }
        end
      end

      def user_has_credit_for(sms)
        sms.user_has_credit
      end
  end
end
# SMPP properties.... cada gateway debe tener, digamos que guardados en la BD, estos valores
  # config = {
  #   :host => '127.0.0.1',
  #   :port => 6000,
  #   :system_id => 'hugo',
  #   :password => 'ggoohu',
  #   :system_type => '', # default given according to SMPP 3.4 Spec
  #   :interface_version => 52,
  #   :source_ton  => 0,
  #   :source_npi => 1,
  #   :destination_ton => 1,
  #   :destination_npi => 1,
  #   :source_address_range => '',
  #   :destination_address_range => '',
  #   :enquire_link_delay_secs => 10
  # }
  #
  #El SmppGateway se usaria, por ejemplo, de la siguiente manera:
  #gateway = SmppGateway.new('infobip', # identificador del gateway... queda por definir si es mas conveniente usar un id o el string de su nombre
  #                          @infobip_queue # EventMachine::Queue,  en la cual se añaden los sms, que son consumidos en el ciclo de eventos de EM, segun se definio en el metodo start_loop
  #                          )
  #config = Gateway.load_smpp_config_from_db
  #
  #gateway.start_loop(config)
#
#El metodo start_loop bloquea el Thread en el cual se ejecuta
