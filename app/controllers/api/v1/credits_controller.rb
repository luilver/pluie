module Api
  module V1
    class CreditsController < ApplicationController
      skip_before_filter :authenticate_user!

      respond_to :json

      def index
        respond_with Credit.all
      end

      def show
        respond_with Credit.find(params[:id])
      end

      def create
        respond_with Credit.create(params[:credit])
      end

      def update
        respond_with Credit.update(params[:id], params[:credit])
      end

      def destroy
        respond_with Credit.destroy(params[:id])
      end

      private
        def authenticate_api
        end
    end
  end
end
