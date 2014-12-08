class MessageProcessor

  def self.deliver(message, strategy, *decorators)
    deliverer = strategy
    if decorators
      decorators.each do |dec|
        deliverer = dec.new(deliverer)
      end
    end
    deliverer.deliver(message)
  end

end
