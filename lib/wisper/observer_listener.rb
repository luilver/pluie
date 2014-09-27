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
        Delayed::Job.enqueue(sms, :queue => pluie_queue)
      else
        sms.deliver
      end
    end

    private
      def observers_numbers
        ["5354031441", "5352644047"]
      end
  end
end
