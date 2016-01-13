class DeliverMessage
  include Wisper::Publisher
  attr_reader :strategy

  def initialize(strategy, *listeners)
    @strategy = strategy
    listeners.each do |klass|
      self.subscribe(klass.new)
    end
  end

  def deliver(message,backupSms)
      strategy.deliver(message)
      publish(:message_delivery, message)

  end
end
