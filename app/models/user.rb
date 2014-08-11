class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :bulk_messages
  has_many :group_messages
  has_many :single_messages
  has_many :contacts
  has_many :groups
  has_many :lists
  has_many :credits
  has_one :api_setting
  belongs_to :gateway
  has_many :sms

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

  def decrease_balance(sms_cost, skip_db_update=false)
    return if sms_cost <= 0
    self.balance -= sms_cost
    save unless skip_db_update
  end

  after_initialize :defaults

  private
    def defaults
      self.gateway ||= Gateway.find_by(name: :infobip) || Gateway.first
    end


end
