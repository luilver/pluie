require 'observer_sms_job'

class ActiveRecord::Base
  def self.choose_random
    constant = self.to_s.constantize
    constant.limit(1).offset(rand(constant.count)).first
  end
end
