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
  has_one  :api_setting, :dependent => :destroy
  has_and_belongs_to_many :routes, -> {distinct}
  has_many :gateways, -> {distinct}, :through => :routes
  has_many :debits
  has_many :bills
  has_many :topups
  has_many :delivery_reports, class_name: "ActionSmser::DeliveryReport"
  has_and_belongs_to_many :roles, ->{distinct}

  def api_key
    self.api_setting.api_key if self.api_setting
  end

  # def api_secret=(api_secret) # no lo tengo concebido con un api_secret
  #   self.api_setting.api_secret = api_secret
  # end






  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def has_credit_for(amount)
    self.balance >= amount
  end

  def bill_sms(sms_cost)
    dbt = self.debits.create(balance: sms_cost)
  end

  def balance
    self.credit - self.debit
  end

  def to_s
    self.email
  end

  def username
    to_s[0,to_s.index('@')]
  end

  def spent
    self.debit
  end

  def debt?; balance < 0 end

  def self.search(search, page)
    paginate :per_page => 10,:page=>page,:conditions=>['email like ?', "%#{search}%"],:order=> {:created_at=>:desc}
  end


  def role?(role_name) #mask_user
    return self.roles.map(&:name).include?(role_name)
  end
  
  def self.search_number(search, page)
    paginate :per_page => 10,:page=>page,:conditions=>['movil_number like ?', "%#{search}%"],:order=> {:created_at=>:desc}
  end
end
