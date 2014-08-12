require_relative 'dispatchers/base'
require 'thread'

module DeliveryMethods

  module ClassMethods

  end

  module InstanceMethods


    def set_sms_dispatcher
      #crea la variable en el controller, a traves de la cual se enviaran los mensajes
      #la idea seria, ejecutar este metodo en cada controller que envie mensajes y luego
      #con los metodos de instancia del modulo SmsApi, se envian los mensajes

      user = current_user
      @dispatcher =  Base.create(user.gateway.name, user)
    end

    def send_message(gateway, user, msg)
      @dispatcher =  Base.create(gateway.name, user)
      receivers =  msg.receivers #numbers that will get the message
      sms_list = receivers.map { |number| Sms.create(gateway, user, msg, number) }

      unless sms_list.empty?
        cost = sms_list.first.cost
        credit_limit = (user.balance / cost).floor
        allowed = sms_list.take(credit_limit)
        allowed.each { |s| s.save }
        @dispatcher.send_sms(allowed)
      end
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
