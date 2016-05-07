class Route < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { distinct }
  belongs_to :gateway
  has_many :single_messages
  has_many :bulk_messages

  before_save :min_value_route
  validates :name, presence: true
  validates :price, presence: true, numericality: {greater_than: 0}
  # validates :user, presence: true
  validates :gateway, presence: true

  scope :publisher_routes , -> { where( system_route: true) }

  def self.notifications_route
    publisher_routes.to_a.first
  end

  def to_s
    self.name
  end

  def gateway_to_sym
    self.gateway.name.downcase.to_sym
  end

  def dlv_to_sym
    "async_#{self.gateway.name.downcase}".to_sym
  end

  def min_value_route
    gateway_most_expensive=Gateway.order(:price=>:desc).first
    if self.price  > gateway_most_expensive.price
      return true
    else
      errors.add(:base, "price tiene que ser  mayor que: #{gateway_most_expensive.price}")
     return false
    end
  end

  def get_price_country_code(phone_number)
    self.price=self.gateway.get_prefix(phone_number.to_s) || self.price_was
  end
end
