class List < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_and_belongs_to_many :list_messages

end
