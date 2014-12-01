class Contact < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :gsm_numbers

  def to_s
    self.name
  end
end
