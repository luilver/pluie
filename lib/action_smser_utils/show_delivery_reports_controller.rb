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
end

ActionSmser::DeliveryReportsController.send :include, ActionSmserUtils::ShowDeliveryReportsController
