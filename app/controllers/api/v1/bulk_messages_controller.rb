module Api
  module V1
    class BulkMessagesController < ApiController

      respond_to :json

      def index
        respond_with User.current.bulk_messages
      end

      def show
        respond_with BulkMessage.find(params[:id])
      end

      def new
        #TODO: allow multiple lists in bulk message
        lists = List.find(params[:list])

        message = BulkMessage.new(
          :message => params[:message],
          :user => User.current
        )
        message.lists << lists
        message.save

        respond_with message
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
    end
  end
end
