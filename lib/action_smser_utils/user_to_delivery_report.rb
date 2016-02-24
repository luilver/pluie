module ActionSmserUtils
  module UserToDeliveryReport
    extend ActiveSupport::Concern

    included do
      belongs_to :user
    end

    module ClassMethods
      def build_with_user(sms, to, msg_id, user, route_name)
        dr = ActionSmser::DeliveryReport.build_from_sms(sms, to, msg_id)
        dr.user = user
        dr.gateway = route_name
        dr.status = ActionSmserUtils::SENT_STATUS
        dr.pluie_id = sms.pluie_id
        dr
      end

      def create_with_user(sms, to, msg_id, user, route_name)
        dr = build_with_user(sms, to, msg_id, user, route_name)
        dr.save
        dr
      end

      def to_csv(options={},reports)
        CSV.generate(options) do |csv|
          csv << [:to,:status]
          reports.each do |dr|
            csv << [dr.to,dr.status]
          end
        end
      end
    end
  end
end

ActionSmser::DeliveryReport.send :include, ActionSmserUtils::UserToDeliveryReport
