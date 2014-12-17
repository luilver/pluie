require 'action_smser_utils/scopes_to_delivery_report'
require 'action_smser_utils/user_to_delivery_report'
require 'action_smser_utils/inspect_request'
require 'smstools'
#user_to_delivery_report file must be loaded in order to add build_with_user method
#and belongs_to association to ActionSmser::DeliveryReport

module ActionSmserUtils
  SENT_STATUS =  "sent"
  DELIVERED_STATUS =  "delivered"
  UNDELIVERED_STATUS = "undelivered"
  MAX_SIZE = 160
  SYSTEM_MSG = "Pluie"

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
    when UNDELIVERED_STATUS
      I18n.translate(:undelivered_status)
    else
      status
    end
  end

  def self.add_info(text, info)
    r = text.dup
    text_size = SmsTools::EncodingDetection.new(text).length
    unless SmsTools::EncodingDetection.new(info + text).concatenated?
      r.insert(0, info)
    end
    r
  end

  def self.sms_parts(body)
    sms_encoding = SmsTools::EncodingDetection.new body
    sms_encoding.concatenated_parts
  end

  def self.sms_cost(number_count, route_price, msg_parts)
    number_count * route_price * msg_parts
  end
end
