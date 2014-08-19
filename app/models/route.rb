class Route < ActiveRecord::Base
  belongs_to :user
  belongs_to :gateway
end
