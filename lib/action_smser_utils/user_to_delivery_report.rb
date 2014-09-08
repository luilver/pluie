module ActionSmserUtils
  module ShowDeliveryReportsController
    extend ActiveSupport::Concern

    included do
      before_action :set_delivery_report, only: [:show]
      load_and_authorize_resource except: [:gateway_commit]

      rescue_from CanCan::AccessDenied do |exception|
        redirect_to main_app.root_url, :alert => exception.message
      end

      def show
      end

      def set_delivery_report
        @delivery_report = ActionSmser::DeliveryReport.find(params[:id])
      end
    end
  end

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

ActionSmser::DeliveryReportsController.send :include, ActionSmserUtils::ShowDeliveryReportsController
