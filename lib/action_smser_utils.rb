require 'action_smser_utils/user_to_delivery_report'
require 'action_smser_utils/inspect_request'
#user_to_delivery_report file must be loaded in order to add build_with_user method
#and belongs_to association to ActionSmser::DeliveryReport

module ActionSmserUtils
  SENT_STATUS =  "sent"
  DELIVERED_STATUS =  "delivered"
  MAX_SIZE = 160
  PLUIE_MSG = "Pluie"

  def self.generate_messages(pluie_msg, batch_size = 10, dlr_method=nil)
    text = pluie_msg.message
    receivers = pluie_msg.receivers
    sms = []

    receivers.each_slice(batch_size) do |batch|
      sms << SimpleSms.multiple_receivers(batch, text, pluie_msg.user.id, pluie_msg.route.id, dlr_method)
    end

    sms
  end

  def self.gateway_callback_url(gateway)
    "http://#{PLUIE_HOST}/delivery_reports/gateway_commit/#{gateway.to_s}"
  end

  def self.admin_access(controller)
    #Allow admin access for every user in order to show delivery reports
    return true
  end

  def self.show_dlr_status(status)
    case status
    when SENT_STATUS
      I18n.translate(:sent_status)
    when DELIVERED_STATUS
      I18n.translate(:delivered_status)
    else
      status
    end
  end

  def self.add_info(text, info)
    r = text.dup
    if info.size + ActionSmser::Base.message_real_length(text) < MAX_SIZE
      r.insert(0, info)
    end
    r
  end

  def self.sms_count
    #how many messages are necessary to send this sms, to 1 recipient using GSM7 encoding
    body_size = ActionSmser::Base.message_real_length(body)
    (body_size / MAX_SIZE) + (body_size % MAX_SIZE == 0 ? 0:1)
  end
end
