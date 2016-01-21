module ApplicationHelper
  class ScheduleUtils
    def self.schedule(job,t = Time.now)
      #donde t es un objeto de tipo Time y job obj de tipo ScheduleSmsJob
      Delayed::Job.enqueue(job,:run_at=>t)
    end
  end
end
