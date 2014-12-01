module PluieWisper
  class MessagePublisher
    include Wisper::Publisher

    def notify_msg_to_observers(msg)
      publish(:pluie_msg_created, msg)
    end

    def sms_sent(sms, numbers)
      publish(:finish_sending, sms, numbers)
    end
  end
end
