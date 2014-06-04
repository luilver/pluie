class Contact < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :groups

  def to_s
    self.name
  end

end
