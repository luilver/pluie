module Api
  module V1
    class SingleMessagesController < ApplicationController
      skip_before_filter :authenticate_user!

      respond_to :json

      def index
        respond_with SingleMessage.all
      end

      def show
        respond_with SingleMessage.find(params[:id])
      end

      def create
        respond_with SingleMessage.create(params[:single_message])
      end

      def update
        respond_with SingleMessage.update(params[:id], params[:single_message])
      end

      def destroy
        respond_with SingleMessage.destroy(params[:id])
      end

      private
        def authenticate_api
        end
    end
  end
end
