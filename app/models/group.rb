class Group < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :contacts
  has_many :gsm_numbers, :through => :contacts

  include Ownable
end
