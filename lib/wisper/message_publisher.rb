module PluieWisper
  class MessagePublisher
    include Wisper::Publisher

    def notify_msg_to_observers(msg)
      if msg.valid?
        publish(:pluie_msg_created, msg)
      end
    end
  end
end
