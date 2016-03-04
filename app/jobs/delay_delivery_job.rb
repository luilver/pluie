DelayDeliveryJob = Struct.new(:message_class, :msg_id, :deliverer, :listeners_strs,:number_from) do
  def perform
    begin
      klass = message_class.constantize
      strategy = deliverer.constantize
      msg = klass.find(msg_id)
      listeners = listeners_strs.map { |l| l.constantize }
      command = DeliverMessage.new(strategy, *listeners)
      command.deliver(msg,number_from)
    rescue Exception => e
      Rails.logger.info "#{klass} with id #{msg_id} not found. Error: #{e.message}"
    end
  end
end
