class List < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_and_belongs_to_many :bulk_messages
  has_attached_file :file

  validates :name, presence: true
  validates_presence_of :file, :message => "can't be blank (only .txt supported)"
  validates_attachment :file, content_type: { content_type: ["text/plain"]}

end
