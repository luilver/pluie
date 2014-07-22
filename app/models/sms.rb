class Sms < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :user
  belongs_to :msg, polymorphic: true

  MAX_SIZE = 160

  def text
    #devolver la propiedad message de single_message o bulk_message
    #(segun este definido en la relacion polimorfica) pero con el encoding
    #asociado al gateway
  end

  def cost
    @cost ||= self.gateway.unit_price * (text.size / MAX_SIZE)
  end
end
