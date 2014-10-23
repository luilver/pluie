module PluieWisper
  class ObserverListener

    attr_reader :delay

    def initialize(delay)
      @delay = delay
    end

    def pluie_msg_created(msg)
      text = ActionSmserUtils.add_info(msg.message, "#{msg.user.username}:")
      job = ObserverSmsJob.new(text, msg)
      if delay
        Delayed::Job.enqueue(job, :queue => pluie_sms_queue)
      else
        job.perform
      end
    end
  end
end
