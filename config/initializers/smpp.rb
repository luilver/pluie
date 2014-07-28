#require 'eventmachine'
require 'smpp_tools/simple_smpp_gateway'

module PluieEM

  def run_loop
    loop do
      EM.run
    end
  end

  def self.start
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked && EM.reactor_running?
          EM.stop
        end
        Thread.new {run_loop}
        die_gracefully_on_signal
      end
    end
  end

  def self.die_gracefully_on_signal
    Signal.trap("INT")  { EM.stop }
    Signal.trap("TERM") { EM.stop }
  end
end

Q_TYPE = ENV["Q_TYPE"] #keep in the env, the kind of queue, ie the kind of producer, used to store sms

PluieEM.start
