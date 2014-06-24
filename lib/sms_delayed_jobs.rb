module DeliveryMethods

  begin
    SimpleMessageJob = Struct.new(:dispatcher, :number, :text) do
      def perform
        dispatcher.send_single_message(number, text)
      end
    end


    MultipleMessageJob = Struct.new(:dispatcher, :numbers, :text) do
       def perform
        if @single_msg.gsm_numbers.count == 1
          @dispatcher.send_single_message(@single_msg.gsm_numbers.first.number, @single_msg.message)
        else
          @dispatcher.send_multiple_messages(@single_msg.gsm_numbers.map { |n| n.number  }, @single_msg.message)
        end
        dispatcher.send_multiple_messages(numbers, text)
       end
     end

  rescue Exception => e
    Rails.logger.error e.message
  end
end
