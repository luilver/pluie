require 'help_string'
require 'action_smser_utils'

module ApplicationHelper

  TOPUP=1.0

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

    def send_message_simple(sm, backup, rt)
      command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
      command.deliver(sm,backup,rt)
      low_cost(sm)
    end

    def self.schedule_job(sm,backup,rt,time)
      job=ScheduleSmsJob.new(sm,backup,rt)
      ScheduleUtils.schedule(job,time)
      low_cost(sm,time)
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

    def low_cost(sms,time=1.minute.from_now)
        Delayed::Job.enqueue(LowBalanceUserJob.new(sms),:run_at=>time)
    end

    def validate_datetime(datetime)
        begin
          Time.new(datetime[:year],datetime[:month],datetime[:day],datetime[:hour],datetime[:minute])
        rescue
          return false
        end
    end
  end
end
