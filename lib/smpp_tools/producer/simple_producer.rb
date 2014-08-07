require_relative 'producer'
require 'eventmachine'

module SmppTools
  class SimpleProducer < Producer

    register_subclass "em_queue"

    attr_reader :queue

    def initialize(name)
      super(name)
      @queue = EM::Queue.new
    end

    def publish(sms)
      @queue << sms
    end

    alias :<< :publish

  end
end
