require_relative 'producer'

module SmppTools
  class SimpleProducer < Producer

    def initialize(name, queue)
      super(name)
      @queue = queue
    end

    def publish(sms)
      @queue << sms
    end

  end
end
