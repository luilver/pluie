require_relative 'smpp_gateway'

module SmppTools
  class SimpleSmppGateway < SmppGateway

    def initialize(name, queue, logger=nil)
      super(name, logger)
      @queue = queue
    end

    def process_next_item
      @queue.pop(fetch_and_send_message)
    end

    def fetch_and_send_message
      Proc.new do |q_sms|
        begin
          send_message(q_sms)
          process_next_item if @queue.num_waiting < 1
        rescue Exception => e
          logger.error e.message
        end
      end
    end

  end
end
