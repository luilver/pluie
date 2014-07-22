#Cada instancia de SmppGateway esta asociada a un Gateway o proveedor que envia mensajes
#(nexmo, infobip, etc) usando una api Smpp.  El nombre(@name) de un SmppGateway debe coincidir
#con el del Gateway asociado a él.
require 'smpp'
MAX_SMS_SIZE = 160

module SmppTools
  class SmppGateway

    attr_reader :name


    def initialize(name, queue, user, logger=nil)
      @name = name
      @msg_queue = queue
      @user = user
      @tx = nil # Smpp::Transceiver
      Smpp::Base.logger =  logger || Rails.logger
    end

    def send_message(sms)
      id, receiver, text = get_fields(sms)
      sender = ""
      m = choose_method(text)

      if @user.has_credit_for(sms.cost)
        m.call(id, sender, receiver, text)
        @user.charge_sms(sms.cost)
      else
        logger.info "#{user.email} has not enough credit. Failed sending sms #{sms.id}"

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
        return txt.size > MAX_SMS_SIZE
      end

      def choose_method(text)
        if large_text(text)
          lambda { | *args | @tx.send_concat_mt(args) }
        else
          lambda { | *args | @tx.send_mt(args) }
      end

  end
end
