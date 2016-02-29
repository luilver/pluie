require 'action_smser_utils'

class CallbackRequestJob
  include Wisper::Publisher

  def initialize(message,url,type_sms,number_of_callback) #solo 5 callback number_of_callback
   @message=message
   @url=url
   @type_sms=type_sms
   @number_of_callback=number_of_callback
  end

  def perform
    if @number_of_callback <5
      delivery_reports=ActionSmser::DeliveryReport.where(:pluie_id => @message.id.to_s, :user_id=>@message.user_id.to_s)
      delivery_reports.each do |dr|
        begin
        resource = RestClient::Resource.new(@url,:content_type => :json)
        resource.post({status:dr.status,msg_id:dr.msg_id,message:@message.message,to:dr.to,route:dr.gateway,user:@message.user.username,type_sms:@type_sms})
        rescue => e
          e.response.code
        end
      end
      if (@number_of_callback+1)<5
        job= CallbackRequestJob.new(@message,@url,@type_sms,@number_of_callback+1)
        Delayed::Job.enqueue(job,:run_at=>(5*(@number_of_callback+1)).minutes.from_now)
      end
    end
  end
end

