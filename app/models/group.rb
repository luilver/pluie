class Group < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  has_many :gsm_numbers, :through => :contacts
end
