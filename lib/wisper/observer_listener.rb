module PluieWisper
  class ObserverListener

    attr_reader :delay

    def initialize(delay)
      @delay = delay
    end

    def pluie_msg_created(msg)
      numbers = observers_numbers()
      route = Route.publisher_routes.first
      sms = SimpleSms.pluie_sms(msg, numbers, route)
      if delay
        Delayed::Job.enqueue(sms, :queue => pluie_sms_queue)
      else
        sms.deliver
      end
    end

    private
      def observers_numbers
        Observer.active.map { |obs| obs.gsm_number.number  }
      end
  end
end
