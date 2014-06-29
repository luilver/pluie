class NexmoJob
  include SuckerPunch::Job

  def initialize
    @nexmo = Nexmo::Client.new(key = ENV['NEXMO_API_KEY'], secret = ENV['NEXMO_API_SECRET'])
  end
end
