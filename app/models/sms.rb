class Sms < ActiveRecord::Base
  belongs_to :gateway
  belongs_to :user
  belongs_to :msg, polymorphic: true

  MAX_SIZE = 160

  def text
    #TODO
    #devolver la propiedad message de single_message o bulk_message
    #(segun este definido en la relacion polimorfica) pero con el encoding
    #asociado al gateway
    self.msg.message
  end

  def cost
    @cost ||= self.gateway.unit_price * msg_count
  end

  def charge_to_user
    self.user.decrease_balance(cost)
  end

  def msg_count
    #How many sms does it take to send the given text
    #This, should be calculated according to the message encoding.
    @msg_count ||= text.size / MAX_SIZE
  end

  def user_has_credit
    self.user.has_credit_for(cost)
  end

  def self.create(gateway, user, msg, receiver)
    sms = Sms.new
    sms.gateway = gateway
    sms.user = user
    sms.msg = msg
    sms.receiver = receiver
    sms
  end

end
