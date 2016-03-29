require 'help_string'
class DeliverMessage
  include Wisper::Publisher
  attr_reader :strategy

  def initialize(strategy, *listeners)
    @strategy = strategy
    listeners.each do |klass|
      self.subscribe(klass.new)
    end
  end

  def deliver(message, backupSms=false, randomText=true,number_from)
     backupSms=backupSms['backupSms'].to_bool if backupSms.class!=FalseClass and backupSms.class!=TrueClass

     if backupSms
       if message.class == SingleMessage
         strategy.deliver(message, randomText,number_from)
         publish(:message_delivery, message)
         if message.user.gateways.count >1
           gt=message.user.gateways.order(:price=>:asc).select{|g| g.id!=message.route.gateway.id}
           listsmessages=[message]
           job= SendSmsBackupJob.new(listsmessages, gt, randomText,number_from) #nuevo message y una ruta menos
           Delayed::Job.enqueue(job,:run_at => 5.minutes.from_now) #manda a ejecutarlo dentro de 5minutos
         end
       end
      else
        strategy.deliver(message, randomText,number_from)
        publish(:message_delivery, message)
      end
  end
end
