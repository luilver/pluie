class GsmNumber < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :lists
end
