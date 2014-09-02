Delayed::Worker.max_attempts = 1
#By default, it will delete failed jobs (and it always deletes successful jobs).
#If you want to keep failed jobs, set Delayed::Worker.destroy_failed_jobs = false.
#The failed jobs will be marked with non-null failed_at.
Delayed::Worker.destroy_failed_jobs = false

def bulk_sms_priority(index)
  index
end

def bulk_sms_queue
  "bulk_sms"
end
