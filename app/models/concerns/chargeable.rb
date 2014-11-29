module Chargeable
  extend ActiveSupport::Concern

  def message_cost
    parts = ActionSmserUtils.sms_parts(self.message || "")
    ActionSmserUtils.sms_cost(self.gsm_numbers_count, self.route.price, parts)
  end
end
