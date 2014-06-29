class NexmoSingleMessageJob < NexmoJob

  def perform(to, text)
    response = @nexmo.send_message({:to => to, :text => text})
  end

end
