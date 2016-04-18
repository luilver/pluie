class Gateway < ActiveRecord::Base
  has_many :users
  has_many :routes
  has_many :users, -> {distinct}, :through => :routes
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :price, numericality: { greater_than: 0 }

  def to_s
    self.name
  end
end
