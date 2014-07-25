#require 'eventmachine'

module PluieEM

  @@msg_queue = EM::Queue.new
  @@configs = {}

  def self.queue
    @@msg_queue
  end

  def self.enqueue(sms)
    queue << sms
  end

  def self.gateway_config(gateway_name)
    config = {
    :host => 'smpp3.infobip.com',
    :port => 8888,
    :system_id => 'pepesenaris',
    :password => 'Jl6KU6It',
    :system_type => '', # default given according to SMPP 3.4 Spec
    :interface_version => 52,
    :source_ton  => 0,
    :source_npi => 1,
    :destination_ton => 1,
    :destination_npi => 1,
    :source_address_range => '',
    :destination_address_range => '',
    :enquire_link_delay_secs => 30
  }

  @@configs[:infobip] = config

  @@configs[gateway_name]

  end

  def self.run_em

    smpp = SimpleSmppGateway.new(:infobip, queue, Rails.logger)
    config =  gateway_config(smpp.name)
    smpp.start_loop(config)
  end

  def self.start
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked && EM.reactor_running?
          EM.stop
        end
        Thread.new {run_em}
        die_gracefully_on_signal
      end
    end
  end

  def self.die_gracefully_on_signal
    Signal.trap("INT")  { EM.stop }
    Signal.trap("TERM") { EM.stop }
  end
end

PluieEM.start
