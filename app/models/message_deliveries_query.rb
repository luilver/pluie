class MessageDeliveriesQuery
  attr_reader :sms_type, :msg_id

  def initialize(sms_type, msg_id, relation = ActionSmser::DeliveryReport.find_each)
    @relation = relation
    @sms_type = sms_type
    @msg_id = msg_id
  end

  def find_each(&block)
    @relation.where(sms_type: sms_type, pluie_id: msg_id).find_each(&block)
  end
end
