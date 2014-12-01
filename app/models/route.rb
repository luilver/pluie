class Route < ActiveRecord::Base
  belongs_to :user
  belongs_to :gateway
  has_many :single_messages
  has_many :bulk_messages

  validates :name, presence: true
  validates :price, presence: true
  validates :user_id, presence: true
  validates :gateway_id, presence: true

  scope :publisher_routes , -> { where( system_route: true) }

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
