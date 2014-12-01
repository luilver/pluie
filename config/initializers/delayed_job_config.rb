Delayed::Worker.max_attempts = 1
#By default, it will delete failed jobs (and it always deletes successful jobs).
#If you want to keep failed jobs, set Delayed::Worker.destroy_failed_jobs = false.
#The failed jobs will be marked with non-null failed_at.
Delayed::Worker.destroy_failed_jobs = false

Delayed::Worker.logger = Rails.logger
Delayed::Worker.delay_jobs = !Rails.env.test?

def bulk_sms_priority(index)
  index
end

FIBER = Fiber.new do
  c = ENV['BULK_SMS_QUEUES_COUNT'].to_i
  q = ENV['BULK_SMS_QUEUE']
  q_names =  (1..c).map { |i| "#{q}_#{i}"}
  q_names.cycle {|name| Fiber.yield name}
end

def bulk_sms_queue
  @@bulk_queue ||= ENV['BULK_SMS_QUEUE']
end

def pluie_sms_queue
  "pluie_queue"
end
