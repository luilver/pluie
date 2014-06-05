class Group < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :group_messages
  has_many :gsm_numbers, :through => :contacts

end
