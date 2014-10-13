module Gsmeable
  extend ActiveSupport::Concern

  include do
    before_save :message_to_gsm
  end

  private
    def message_to_gsm
      #TODO   do transliteration, ie transform to similars symbols does that dont have a direct mapping
      sms_encoding = SmsTools::EncodingDetection.new self.message
      if sms_encoding.unicode? && (SmsTools::GsmEncoding.valid? self.message)
        self.message =  (SmsTools::GsmEncoding.from_utf8 self.message)
      end
    end
end
