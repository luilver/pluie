require 'action_smser_utils'

BackupSingleMessageMaskJob = Struct.new(:list_messages, :gateways, :randomText,:number_from) do
  def perform
    begin
      deliver=false
      list_messages.each do |message|
        dr = ActionSmser::DeliveryReport.where(:pluie_id => message.id.to_s,:sms_type=>SingleMessage.to_s).first
        if  dr.status == ActionSmserUtils::DELIVERED_STATUS
          deliver=true
        end
      end

      message = list_messages.last()
      if !deliver
        if gateways.count > 0
          sm=SingleMessage.new
          sm.number=message.number
          sm.message=message.message
          sm.user_id=User.find_by_email('pluie@openbgs.com').id #recarga esto al sistema, el respaldo es por el sistema
          sm.route=User.find(sm.user_id).routes.order(:price=>:asc).select{|r| r.gateway_id==gateways.first.id}.first
          sm.save
          SingleDeliverer.deliver(sm,randomText,number_from)
          list_messages << sm

          if gateways.count>1
            job= BackupSingleMessageMaskJob.new(list_messages, gateways.last(gateways.count-1), randomText,number_from) #nuevo message y una ruta menos
            Delayed::Job.enqueue(job,:run_at => 5.minutes.from_now) #manda a ejecutarlo dentro de 5minutos
          end
        end
      end
    rescue Exception => e
      Rails.logger.info "Error: #{e.message}"
    end
  end
end
