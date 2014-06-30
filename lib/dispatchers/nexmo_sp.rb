require 'dispatchers/nexmo_http'

module DeliveryMethods

  class NexmoSp < NexmoHttp
    attr_reader :bulk_batch_size

    def initialize
      super
      @bulk_batch_size = 50
    end

    def send_single_message(to, text)
      NexmoSingleMessageJob.new.async.perform(to, text)
    end

    def send_multiple_messages(numbers, text)
      NexmoMultipleMessageJob.new.async.perform(numbers, text)
    end

    def send_bulk_messages(numbers, text)
      numbers.each_slice(@bulk_batch_size) do |batch|
         NexmoMultipleMessageJob.new.async.perform(batch, text)
      end
    end
  end
end
