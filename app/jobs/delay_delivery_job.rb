DelayDeliveryJob = Struct.new(:message_class, :msg_id) do
  def perform
    begin
      klass = message_class.constantize
      msg = klass.find(msg_id)
      msg.deliver
    rescue Exception => e
      Rails.logger.info "#{klass} with id #{msg_id} not found. Error: #{e.message}"
    end
  end
end
