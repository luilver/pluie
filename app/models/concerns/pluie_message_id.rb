module PluieMessageId
  extend ActiveSupport::Concern

  def pluie_message_id
    "#{pluie_type}_#{self.id}"
  end

  def pluie_type
    self.class.to_s
  end
end
