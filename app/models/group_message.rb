class GroupMessage < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :groups
  validates :message, presence: true

end
