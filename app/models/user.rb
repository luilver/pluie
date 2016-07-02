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
  has_many :historic_logs

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
    if !(search !~ /\D/)
      paginate :per_page => 10,:page=>page,:conditions=>['email like ?', "%#{search}%"],:order=> {:created_at=>:desc}
    else
      paginate :per_page => 10,:page=>page,:conditions=>['movil_number like ?', "%#{search}%"],:order=> {:created_at=>:desc}
    end
  end

  # def self.search_number(search, page)
  #   paginate :per_page => 10,:page=>page,:conditions=>['movil_number like ?', "%#{search}%"],:order=> {:created_at=>:desc}
  # end

  def query_home
    return {:today=>count_message('today'),:h_48=>count_message('48_last_hour'),:t_week=>count_message('week'),:d_15=>count_message('15_last_days'),:t_month=>count_message('this_month'),:d_60=>count_message('60_last_days'),:t_year=>count_message('this_year'),:d_500=>count_message('500_last_day'),:l_hour=>count_message('last_hour')}
  end

  def count_message(date)
    time_span = case date.to_s.downcase
                  when '48_last_hour'
                    48.hour.ago..Time.current
                  when 'week'
                    Time.current.at_beginning_of_week..Time.current
                  when '15_last_days'
                    15.days.ago..Time.current
                  when 'this_month'
                    Time.current.at_beginning_of_month..Time.current
                  when '60_last_days'
                    60.days.ago..Time.current
                  when 'today'
                    Time.current.at_beginning_of_day..Time.current
                  when 'this_year'
                    Time.current.at_beginning_of_year..Time.current
                  when '500_last_day'
                    500.days.ago..Time.current
                  when 'last_hour'
                    1.hour.ago..Time.current
                  when /^(\d\d)-(\d\d) hours/
                    $1.to_i.hours.ago..$2.to_i.hours.ago
                  else
                    1.week.ago..Time.current
                end
      if self.admin?
            count_message= ActionSmser::DeliveryReport.where(:created_at => time_span).count
      else
            count_message= ActionSmser::DeliveryReport.where(:user_id=>self.id).where(:created_at => time_span).count
      end
      return count_message
  end

  def role?(role_name) #mask_user
    return self.roles.map(&:name).include?(role_name)
  end
end
