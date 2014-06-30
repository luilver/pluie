class NexmoSingleMessageJob < NexmoJob

  def perform(to, text)
    begin
      response = @nexmo.send_message({:to => to, :text => text})
    rescue Exception => e
      Rails.logger.error "<<<<<<<<<<<<<Error on Single Message sending: #{e.message}>>>>>>>>>>>>>>>>>"
    end

  end

end
