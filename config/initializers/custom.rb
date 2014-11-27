require 'observer_sms_job'

class ActiveRecord::Base
  def self.choose_random
    constant = self.to_s.constantize
    constant.send(:all)[rand constant.send(:count)]
  end
end
