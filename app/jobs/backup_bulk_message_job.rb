require 'action_smser_utils'


#list_messages es un hash donde se van adicionando los id de los mensajes hijos en :id
BackupBulkMessageJob = Struct.new(:list_messages, :gateways, :randomText,:number_from,:id_original_bm,:number_original_bm) do
  def perform
    begin
      deliver=false
      dr = ActionSmser::DeliveryReport.where(:pluie_id => id_original_bm.to_s,:sms_type=>BulkMessage.to_s,:to => number_original_bm).first #cuando se ejecute el trabajao el unicod identificador univoco es el numero de destinatario
      if !dr.nil?
        return if dr.status == ActionSmserUtils::DELIVERED_STATUS
      end
      list_messages[:id].each do |message|
        dr = ActionSmser::DeliveryReport.where(:pluie_id => message.to_s,:sms_type=>SingleMessage.to_s,:to => number_original_bm).first
        if  dr.status == ActionSmserUtils::DELIVERED_STATUS
          deliver=true
        end
      end

      # message = SingleMessage.new(:message=>list_messages[:message],:number=>list_messages[:number],:user_id=>list_messages[:user_id])
      if !deliver
        if gateways.count > 0
          sm=SingleMessage.new
          sm.number=list_messages[:number]
          sm.message=list_messages[:message]
          sm.user_id=User.find_by_email('pluie@openbgs.com').id #el respaldo es por el sistema con el usuario pluie
          sm.route=User.find(sm.user_id).routes.order(:price=>:asc).select{|r| r.gateway_id==gateways.first.id}.first
          sm.bm_descendent=id_original_bm
          sm.save
          SingleDeliverer.deliver(sm,randomText,number_from)
          list_messages[:id] << sm.id

          if gateways.count>1
            job= BackupBulkMessageJob.new(list_messages, gateways.last(gateways.count-1), randomText,number_from,id_original_bm,number_original_bm) #nuevo message y una ruta menos
            Delayed::Job.enqueue(job,:run_at => 5.minutes.from_now) #manda a ejecutarlo dentro de 5minutos
          end
        end
      end
    rescue Exception => e
      Rails.logger.info "Error: #{e.message}"
    end
  end
end
