require 'action_smser_utils'

module Api
  module V1
    class DeliveryReportsController < ApiController

      respond_to :json

     def show
       begin
          sms_id=params[:sms_id]
          val_array=sms_id.split(':')
          id=val_array[0]
          type_val=type(val_array[1])
          if type_val
            delivery_report_val=ActionSmser::DeliveryReport.where(:pluie_id=>id,:sms_type=>type_val,:user_id=>User.current.id)
            render json: {:sms_id=>params[:sms_id],:delivery_reports=> delivery_report_val.map { |dr| {:status=>I18n.translate(dr.status.to_s+'_status',:locale=>User.current.locale),:to=>dr.to}}}, :status=>200
          else
           log_not_authorized_access
           render json: {:message=>'incorrect parameter sms_id'}, :status=>422
          end
       rescue
         log_not_authorized_access
         render json: {:message=>'incorrect parameter sms_id'}, :status=>422
       end
     end

     protected

     def type(type_str)
       begin
         if type_str=='SM'
           return SingleMessage.to_s
         elsif type_str=='BM'
           return BulkMessage.to_s
         else
           return false
         end
       rescue
         return false
       end
     end
    end
  end
end
