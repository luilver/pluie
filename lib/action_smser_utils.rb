require 'action_smser_utils/user_to_delivery_report'
#user_to_delivery_report file must be loaded in order to add build_with_user method
#and belongs_to association to ActionSmser::DeliveryReport

module ActionSmserUtils
  def self.generate_messages(pluie_msg, dlr_method=nil, batch_size = 10)
    text = pluie_msg.message
    receivers = pluie_msg.receivers
    sms = []

    receivers.each_slice(batch_size) do |batch|
      sms << SimpleSms.multiple_receivers(batch, text, dlr_method)
    end

    sms
  end
end
