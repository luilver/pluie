class Route < ActiveRecord::Base
  belongs_to :user
  belongs_to :gateway
  has_many :single_messages
end
