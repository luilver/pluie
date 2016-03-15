require 'action_smser_utils'

class NotifiedDeliveryReportSmsJob

  def initialize(message_id,phone_to_notified,type)
    @message_id=message_id
    @phone_to_notified=phone_to_notified
    @type=type
  end

  def perform
    user = @type==BulkMessage.to_s ? BulkMessage.find(@message_id.to_i).user : SingleMessage.find(@message_id.to_i).user
    @phone_to_notified= user.movil_number if @phone_to_notified == nil and !user.confirm_token_number.blank?

    if !@phone_to_notified.blank?
      sms_of_user=ActionSmser::DeliveryReport.where(:pluie_id=>@message_id.to_s)
      delivered = porcent(sms_of_user,"delivered")
      sent = porcent(sms_of_user,"sent")
      undelivered = porcent(sms_of_user,"undelivered")

      s=SingleMessage.new
      s.user=user
      s.message="Plantilla: \n"
      s.message= s.message + "!Su envìo se ha realizado satisfactoriamente!"
      s.message= s.message+'\n'+  I18n.translate(:delivered_status).to_s + "  " + delivered[:status].to_s + " sms " + "(" + delivered[:porcent_sms].to_s+ "%)"
      s.message= s.message+'\n'+  I18n.translate(:sent_status).to_s   + "  " + sent[:status].to_s + " sms " + "(" + sent[:porcent_sms].to_s+ "%)"
      s.message= s.message+'\n'+  I18n.translate(:undelivered_status_notified).to_s + "  " + undelivered[:status].to_s + " sms " + "(" + undelivered[:porcent_sms].to_s+ "%)"
      s.message=s.message+ '\n'+ 'Knal.es'
      s.message=s.message.gsub!('\n',"\n")
      s.route=user.routes.order(:price=>:asc).first
      s.number=@phone_to_notified.to_s

      if s.save
        command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
        command.deliver(s,true,true,rand(10000...99999)) #con respaldo y randomText
      end
    end
  end

  def porcent(messages_reports,status)
    obj=nil
    if @type=="BulkMessage"
      obj=BulkMessage.find(@message_id.to_i)
    else
      obj=SingleMessage.find(@message_id.to_i)
    end

    ret=[]
    messages_reports.each do |report|
      if report.status==status
          ret << report
      end
    end
    porcent_sms= (100.0*ret.count.to_f)/obj.receivers.count.to_f
    return {:status=> ret.count, :porcent_sms=> porcent_sms}
  end
end

