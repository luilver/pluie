class DeliveryNotifier
  attr_reader :delay

  def initialize(deliverer)
    @msg_processor = deliverer
    @delay = Rails.env.production?
  end

  def deliver(message)
    @msg_processor.deliver(message)
    notify_to_observers(message)
  end

  private
    def notify_to_observers(message)
      job = ObserverSmsJob.new(text_to_observer(message), message.receivers)
      if delay
        Delayed::Job.enqueue(job, :queue => pluie_sms_queue)
      else
        job.perform
      end
    end

    def text_to_observer(message)
      username = message.user.username
      text = message.message
      ActionSmserUtils.add_info(text, username)
    end


end
