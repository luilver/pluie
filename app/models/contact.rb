class Contact < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :gsm_numbers
  belongs_to :main_number, class_name: 'GsmNumber', foreign_key: 'gsm_number_id'

  def to_s
    self.name
  end
end
