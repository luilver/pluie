module PluieWisper
  class MessagePublisher
    include Wisper::Publisher

    def sms_sent(sms, numbers)
      publish(:finish_sending, sms, numbers)
    end
  end
end
