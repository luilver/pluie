SmsInfo = Struct.new(:id,  :receiver, :text, :cost,  :gateway_id, :user_id)  do
#el costo del mensaje se calcula previamente a partir del precio del
#gateway por que el que se envia y el tamaño del mensaje
#los mensajes que superan el tamaño maximo de 1 sms,
#se consideran como un solo mensaje a los efectos del sistema y el usuario,
#aunque para enviarlos, sea necesario componer varios sms. Por ejemplo un
#mensaje de 300 caracteres tendra asociado un solo reporte de entrega.
#
#receiver se refiere al numero al cual se le envia el mensaje.
#se tiene en cuanta el caso de que un mismo mensaje sea enviado a varios numeros
#al  unisono, pero en general se espera que cada sms, tenga un unico destinatario

  def numbers
    receiver.split(" ")
  end

  def single_receiver?
    numbers.size == 1
  end

  def to_str
    "Msg #{id} for #{receiver.truncate(35)} says #{text.truncate(10)}"
  end

  def gateway
    Gateway.find(gateway_id)
  end

  def user
    User.find(user_id)
  end

  def charge_sms_to_user
    user.decrease_balance(cost)
  end
end
