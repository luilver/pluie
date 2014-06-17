module SmsApi

    SingleMessageJob = Struct.new(:dispatcher, :single_msg) do

        def perform
          if single_msg.gsm_numbers.count == 1
            dispatcher.send_single_message(single_msg.gsm_numbers.first.number, single_msg.message)
          else
            dispatcher.send_multiple_messages(single_msg.gsm_numbers.map { |n| n.number  }, single_msg.message)
          end
        end

    end
end
