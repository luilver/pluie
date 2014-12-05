class GsmNumber < ActiveRecord::Base
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :single_messages
  has_and_belongs_to_many :bulk_messages
  has_one :observer

  validates :number, format: { with: /535[0-9]{7}/, message: I18n.t('errors.messages.valid_gsm_number_format').html_safe}

  def self.find_by_number_or_create(num)
    GsmNumber.find_by_number(num) || GsmNumber.create(:number => num)
  end

  def to_s
    self.number
  end
end
