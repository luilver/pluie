module ActionSmserUtils
  module UserToDeliveryReport
    extend ActiveSupport::Concern

    included do
      belongs_to :user
    end


    module ClassMethods
      def build_with_user(sms, to, msg_id, user)
        dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, msg_id, route_name)
        dr.user = user
        dr.gateway = route_name
        dr
      end

      def create_with_user(sms, to, msg_id, user, route_name)
        dr = build_with_user(sms, to, msg_id, user, route_name)
        dr.save
        dr
      end
    end
  end
end

ActionSmser::DeliveryReport.send :include, ActionSmserUtils::UserToDeliveryReport

