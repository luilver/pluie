module Api
  module V1
    class SingleMessagesController < ApiController

      respond_to :json

      def index
        respond_with User.current.single_messages
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
    end
  end
end
