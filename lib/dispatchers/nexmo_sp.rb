require 'dispatchers/nexmo_http'

module DeliveryMethods

  class NexmoSp < NexmoHttp

    def send_single_message(to, text)
      NexmoSingleMessageJob.new.async.perform(to, text)
    end

    def send_multiple_messages(numbers, text)
      NexmoMultipleMessageJob.new.async.perform(numbers, text)
    end
  end
end
