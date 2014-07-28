#require 'eventmachine'
require 'smpp_tools/simple_smpp_gateway'

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
    #las configuraciones se deben cargar de la BD o del enviroment.
    config = {
    :host => 'smpp3.infobip.com',
    :port => 8888,
    :system_id => INFOBIP_KEY,
    :password => INFOBIP_PASS,
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
  #TODO ... confirmar loa valores de  los ultimos parametros de configuracion de infobip

  @@configs[:infobip] = config

  @@configs[gateway_name]

  end

  def self.run_em
    begin
      smpp = SimpleSmppGateway.new(:infobip, queue, Rails.logger)
      config =  gateway_config(smpp.name)
      smpp.start_loop(config)
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

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

PluieEM.start
