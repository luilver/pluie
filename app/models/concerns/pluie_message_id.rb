module PluieMessageId
  extend ActiveSupport::Concern

  def pluie_message_id
    "#{self.class.to_s}_#{self.id}"
  end
end
