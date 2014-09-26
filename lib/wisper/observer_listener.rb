module PluieWisper
  class ObserverListener

    attr_accessor :route
    attr_reader :delay

    def initialize(route, delay)
      @route = route
      @delay = delay
    end

    def pluie_msg_created(msg)
      numbers = observers_numbers()
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
