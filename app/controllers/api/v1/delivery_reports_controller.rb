module Api
  module V1
    class DeliveryReportsController < ApiController

      respond_to :json

      def index
        respond_with DeliveryReport.all
      end

      def show
        respond_with DeliveryReport.find(params[:id])
      end

    end
  end
end
