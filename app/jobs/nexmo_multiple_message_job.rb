class NexmoMultipleMessageJob < NexmoJob

  def perform(numbers, text)
    begin
      numbers.each do |number|
      @nexmo.send_message({:to => number, :text => text})
      end
    rescue Exception => e
      Rails.logger.error "<<<<<<<<<<<<Error #{e.message} while sending msg:#{text.truncate(12)} to [#{numbers.join("--")}]>>>>>>>>>>>>>>>>"
    end
  end

end
