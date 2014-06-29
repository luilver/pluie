class NexmoMultipleMessageJob < NexmoJob

  def perform(numbers, text)
    numbers.each do |number|
      @nexmo.send_message({:to => number, :text => text})
    end
  end

end
