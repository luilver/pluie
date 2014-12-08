DelayDeliveryJob = Struct.new(:message_class, :msg_id, :deliverer, :decorators) do
  def perform
    begin
      klass = message_class.constantize
      dlv = deliverer.constantize
      msg = klass.find(msg_id)
      decs = decorators.map { |d| d.constantize }
      MessageProcessor.deliver(msg, dlv, decs)
    rescue Exception => e
      Rails.logger.info "#{klass} with id #{msg_id} not found. Error: #{e.message}"
    end
  end
end
