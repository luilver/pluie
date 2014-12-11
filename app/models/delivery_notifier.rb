class DeliveryNotifier
  attr_reader :delay

  def initialize
    @delay = Rails.env.production?
  end

  def message_delivery(message)
    job = ObserverSmsJob.new(text_to_observer(message), message.receivers)
    if delay
      Delayed::Job.enqueue(job, :queue => pluie_sms_queue)
    else
      job.perform
    end
  end

  private
    def text_to_observer(message)
      username = message.user.username
      text = message.message
      ActionSmserUtils.add_info(text, username)
    end
end
