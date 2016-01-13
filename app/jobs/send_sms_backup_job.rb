require 'action_smser_utils'

SendSmsBackupJob = Struct.new(:message, :routes) do
  def perform
    begin
      dr = ActionSmser::DeliveryReport.where(:pluie_id => message.id.to_s).first
      if dr.status != ActionSmserUtils::DELIVERED_STATUS
        if routes.count >0
          sm=SingleMessage.new
          sm.number=message.number
          sm.message=message.message
          sm.user_id=message.user_id
          sm.route=routes.first
          sm.save
          SingleDeliverer.deliver(sm)

          if routes.count>1
          job= SendSmsBackupJob.new(sm, routes.last(routes.count-1)) #nuevo message y una ruta menos
          Delayed::Job.enqueue(job,:run_at => 5.minutes.from_now) #manda a ejecutarlo dentro de 5minutos
          end
        end
      end
    rescue Exception => e
      Rails.logger.info "Error: #{e.message}"
    end
  end
end
