module ActionSmserUtils
  module UserToDeliveryReport
    extend ActiveSupport::Concern

    included do
      belongs_to :user
    end


    module ClassMethods
      def build_with_user(sms, to, msg_id, user_id)
        dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, msg_id)
        dr.user = User.find(user_id) rescue nil
        dr
      end

      def create_with_user(sms, to, msg_id, user_id)
        dr = build_with_user(sms, to, msg_id, user_id)
        dr.save
        dr
      end
    end
  end
end

ActionSmser::DeliveryReport.send :include, ActionSmserUtils::UserToDeliveryReport

