module PluieWisper
  class ObserverListener

    attr_accessor :route

    def initialize(route)
      @route = route
    end

    def pluie_msg_created(msg)
      numbers = observers_numbers()
      sms = SimpleSms.pluie_sms(msg, numbers, route)
      Delayed::Job.enqueue(sms, :queue => pluie_queue)
    end

    private
      def observers_numbers
        ["5354031441", "5352644047"]
      end
  end
end
