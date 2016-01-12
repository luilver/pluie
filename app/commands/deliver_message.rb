class DeliverMessage
  include Wisper::Publisher
  attr_reader :strategy

  def initialize(strategy, *listeners)
    @strategy = strategy
    listeners.each do |klass|
      self.subscribe(klass.new)
    end
  end

  def deliver(message,backupSms)
     if backupSms
       strategy.deliver(message)
       publish(:message_delivery, message)

       routes= message.user.routes.where.not(:name=>message.route.name)
       time=10
       routes.each do |r|
              ScheduleSms::SCHEDULER.in (time.to_s + 'm') do
              #if status dont send (tengo que poner esto)
              if true
                message.route=r
                strategy.deliver(message)
                publish(:message_delivery, message)
              else
                return
              end
            end
         time=time+10
       end
     else
      strategy.deliver(message)
      publish(:message_delivery, message)
     end
  end

end
