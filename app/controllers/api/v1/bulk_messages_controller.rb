module Api
  module V1
    class BulkMessagesController < ApplicationController
      skip_before_filter :authenticate_user!

      respond_to :json

      def index
        respond_with BulkMessage.all
      end

      def show
        respond_with BulkMessage.find(params[:id])
      end

      def create
        respond_with BulkMessage.create(params[:bulk_message])
      end

      def update
        respond_with BulkMessage.update(params[:id], params[:bulk_message])
      end

      def destroy
        respond_with BulkMessage.destroy(params[:id])
      end

      private
        def authenticate_api
        end
    end
  end
end
