class Gateway < ActiveRecord::Base
  has_many :users
  has_many :sms
  has_many :routes
  has_many :users, :through => :routes

  def to_s
    self.name
  end
end
