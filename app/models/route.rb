class Route < ActiveRecord::Base
  has_and_belongs_to_many :users, -> { distinct }
  belongs_to :gateway
  has_many :single_messages
  has_many :bulk_messages

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
end
