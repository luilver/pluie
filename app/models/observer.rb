class Observer < ActiveRecord::Base
  include Wisper.model
  belongs_to :gsm_number
  validates :number, :presence => true
  validates :number, format: { with: /535[0-9]{7}/, message: I18n.t('errors.messages.valid_gsm_number_format').html_safe}
  before_save :relate_number

  scope :active, -> { where(active: true)}

  def self.active_numbers
    active.pluck(:number)
  end

  private
    def relate_number
      self.gsm_number = GsmNumber.find_or_create_by(number: self.number)
    end
end
