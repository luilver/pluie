#Cada instancia de SmppGateway esta asociada a un Gateway o proveedor que envia mensajes
#(nexmo, infobip, etc) usando una api Smpp.  El nombre(@name) de un SmppGateway debe coincidir
#con el del Gateway asociado a él.
require 'smpp'


module SmppTools

  MAX_SMS_SIZE = 160
  WAIT_TIME = 5

  class SmppGateway

    attr_reader :name


    def initialize(name, queue, logger=nil)
      @name = name
      @queue = queue # EM:Queue  utilizada para obtener los sms.
      @tx = nil # Smpp::Transceiver
      Smpp::Base.logger =  logger || Rails.logger
    end

    def send_message(sms)
      id, receiver, text = get_fields(sms)
      sender = ""
      m = choose_method(text)

      if user_has_credit_for(sms)
        m.call(id, sender, receiver, text)
        sms.charge_to_user
      else
        logger.info "#{user.email} has not enough credit. Failed sending sms #{sms.id}"
      end

    end

    def start_loop(config)

      process_msg = Proc.new do |q_sms|
        begin
          send_message(q_sms)
          @queue.pop(process_msg)
        rescue Exception => e
          logger.error e.message
        end

      end

      loop do
        EM::run do
          @tx = EM::connect(
            config[:host], config[:port],
            Smpp::Transceiver,
            config,
            self   # Receive callbacks on Delivery Reports and other events
            )

          @queue.pop(process_msg)
        end

        logger.info "Disconnected. Reconnecting in #{WAIT_TIME} seconds"
        sleep(WAIT_TIME)
      end
    end

    protected

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
        logger.info "Delegate: transceiver bound"
      end

      def unbound(transceiver)
        logger.info "Delegate: transceiver unbound"
        EventMachine::stop_event_loop
      end


    private

      def logger
        Smpp::Base.logger
      end

      def get_fields(sms)
        return sms.id, sms.receiver, sms.text
      end

      def large_text(txt)
        return txt.size > Sms.MAX_SIZE
      end

      def choose_method(text)
        if large_text(text)
          lambda { | *args | @tx.send_concat_mt(*args) }
        else
          lambda { | *args | @tx.send_mt(*args) }
        end
      end

      def user_has_credit_for(sms)
        sms.user.has_credit_for(sms.cost)
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
