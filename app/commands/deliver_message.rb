class DeliverMessage
  include Wisper::Publisher
  attr_reader :strategy

  def initialize(strategy, *listeners)
    @strategy = strategy
    listeners.each do |klass|
      self.subscribe(klass.new)
    end
  end

  def deliver(message,backupSms=false)
      if backupSms
       if message.class == SingleMessage
         strategy.deliver(message)
         publish(:message_delivery, message)
         if message.user.routes.count > 1
           rt=message.user.routes.order(price: :asc).select{|r| r.id!=message.route.id}
           listsmessages=[message]
           job= SendSmsBackupJob.new(listsmessages, rt) #nuevo message y una ruta menos
           Delayed::Job.enqueue(job,:run_at => 5.minutes.from_now) #manda a ejecutarlo dentro de 5minutos
         end
       end
      else
        strategy.deliver(message)
        publish(:message_delivery, message)
      end
  end
end
