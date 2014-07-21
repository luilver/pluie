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

      def new
        #TODO: allow multiple recipients in single message
        numbers = GsmNumber.find_by_number_or_create(params[:number])

        message = SingleMessage.create(
           :message => params[:message],
           :number => params[:number],
           :user => User.current
        )
        message.gsm_numbers << numbers
        message.save

        respond_with message
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
