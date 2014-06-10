class GsmNumber < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :single_messages
  has_and_belongs_to_many :bulk_messages
end
