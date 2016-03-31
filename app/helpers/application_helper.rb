require 'help_string'
require 'action_smser_utils'

module ApplicationHelper
  class ScheduleUtils
    def self.schedule(job,t = Time.now)
      #donde t es un objeto de tipo Time y job obj de tipo ScheduleSmsJob
      Delayed::Job.enqueue(job,:run_at=>t)
    end
  end

  class ManageSM
      def validate_rt(rt) # valida el random text y lo convierte en bool si es string
        return true unless rt!=nil
        if rt.class==String
          return rt.to_bool
        end
        return rt.to_s.to_bool
      end

    def validate_backup(backup)
      return false if backup==nil
      if backup.class==String
        return backup.to_bool
      end
      return backup
    end

    def check_time(time)
      if time.class==Time
        if time >=Time.now
          return true
        end
      end
      return false
    end

    def send_message_simple(sm, backup, rt,number_from)
      command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
      command.deliver(sm,backup,rt,number_from)
    end

    def self.schedule_job(sm,backup,rt,time,number_from)
      job=ScheduleSmsJob.new(sm,backup,rt,number_from)
      ScheduleUtils.schedule(job,time)
    end

    def notified_sms(id,phone,name_message)
      job =NotifiedDeliveryReportSmsJob.new(id,phone,name_message)
      Delayed::Job.enqueue(job,:run_at => 30.minutes.from_now)
    end

    def callback_request(url,message)
      if !url.blank?
        job = CallbackRequestJob.new(message,url,message.class.to_s,0)
        Delayed::Job.enqueue(job,:run_at=> 5.minutes.from_now)
      end
    end

    def convertTodate(date,time)
      day,month,year=date.split("/")
      #Time.new(date["year"].to_i,date["month"].to_i,date["day"].to_i,date["hour"].to_i,date["minute"].to_i,)
      begin
        Time.new(year.to_i,month.to_i,day.to_i,time['hour'].to_i, time['minute'].to_i)
      rescue
        return nil
      end
    end

    def convert_to_num(n)
        begin
          num= Integer n
          return num.to_s[0..4].to_i if (Math.log10(num).to_i+1) > 5
          return rand(10000...99999) if (Math.log10(num).to_i+1) < 5
          return num
        rescue
           rand(10000...99999)
        end
    end

    def message_of_confirmation(user,movil_number)
      user.confirm_token_number=nil if !user.confirm_token_number.nil?
      klave= SecureRandom.hex(2)
      sm=SingleMessage.new
      sm.user=user
      sm.route=user.routes.order(:price=>:asc).first
      sm.message=I18n.translate('message_confirm',:klave=>klave)
      sm.number=movil_number.to_s
      if sm.save
        sm.user.token_number=klave.to_s
        sm.user.save
        send_message_simple(sm,false,true,rand(10000...99999))
      end
    end

    def validate_datetime(datetime)
        begin
          Time.new(datetime[:year],datetime[:month],datetime[:day],datetime[:hour],datetime[:minute])
        rescue
          return false
        end
    end
  end

  class CallbackManage
      def self.call_callback_request(delivery_reports)
            delivery_reports.group_by {|r| [r.pluie_id, r.sms_type]}.each do |g| #g es un grupo formado por dos elementos [0] el elemento porque filtro y en [1] el grupo como tal Array
                list_dr=[]
                g[1].each do |dr|
                  info ={status:dr.status,msg_id:dr.msg_id,to:dr.to,route:dr.gateway,message:dr.body,user:User.find(dr.user_id.to_i).username}
                  list_dr << info
                end
                begin
                  url=''
                  dr= ActionSmser::DeliveryReport.where(:pluie_id=>g[0][0], :sms_type=>g[0][1]).first
                  if dr.sms_type==SingleMessage.to_s
                    url=SingleMessage.find(g[0][0].to_i).url_callback
                  else
                    url =BulkMessage.find(g[0][0].to_i).url_callback
                  end
                  if url.blank?
                    url=User.find(g[1].first.user_id.to_i).url_callback
                  end
                  if !url.blank?
                    resource = RestClient::Resource.new(url,:content_type => :json)
                    resource.post({pluie_callback:list_dr})
                  end
                rescue => e
                    e.response.code
                end
            end
      end
  end
end
