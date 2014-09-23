class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :bulk_messages
  has_many :group_messages
  has_many :single_messages
  has_many :contacts
  has_many :groups
  has_many :lists
  has_many :credits
  has_one :api_setting
  has_many :sms
  has_many :routes
  has_many :gateways,  :through => :routes
  has_many :debits

  def api_key
    self.api_setting.api_key
  end
  def api_secret=(api_secret)
    self.api_setting.api_secret = api_secret
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def has_credit_for(amount)
    self.balance >= amount
  end

  def bill_sms(sms_count, route_price)
    sms_cost = route_price * sms_count
    decrease_balance(sms_cost)
  end

  def decrease_balance(sms_cost, skip_db_update=false)
    return if sms_cost <= 0
    self.balance -= sms_cost
    save unless skip_db_update
  end

  def to_s
    self.email
  end

  def username
    to_s[0,to_s.index('@')]
  end

  def self.random
    User.all[rand User.count]
  end

  def spent
    total = 0
    credits.each { |c| total += c.balance }
    debt? ? total : total - balance
  end

  def debt; debt? ? balance * -1 : 0 end
  def debt?; balance < 0 end
end
