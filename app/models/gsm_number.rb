class GsmNumber < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :single_messages
  has_and_belongs_to_many :bulk_messages

  def self.find_by_number_or_create(num)
    GsmNumber.find_by_number(num) || GsmNumber.create(:number => num)
  end
end
