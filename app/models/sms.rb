class Sms < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :user
  belongs_to :msg, polymorphic: true
end
