require 'action_smser_utils'

module Api
  module V1
    class SingleMessagesController < ApiController

      respond_to :json

      def index
        render json: {:messages => User.current.single_messages.map{|mess| {:message=>mess.message, :destinatarios=>mess.gsm_numbers.count, :identifier=>mess.id}}
               },status: 200
      end

      def show
        if not User.current.single_messages.where(:id=>params[:id]).blank?
        render json: {:message=>  User.current.single_messages.find(params[:id]).message, :number=> User.current.single_messages.find(params[:id]).receivers}, status: 200
        else
          render json: {:message=>"Not exist message with that identifier"}, status: 404
        end
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
