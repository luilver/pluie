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
          render json: {:message=>  User.current.single_messages.find(params[:id]).message, :number=> User.current.single_messages.find(params[:id]).receivers,:identifier=>params[:id]}, status: 200
        else
          render json: {:message=>"Not exist message with that identifier"}, status: 404
        end
      end

      def new
          render json: {:message=> "this resource is not available"},status: 301
      end

      def create
          numbersPhone=params[:single_message][:numbers]
          route=params[:single_message][:route]
          message=params[:single_message][:message]

          if not User.current.routes.find_by_name(route).blank?
            @single_message=SingleMessage.new(:user_id=>User.current.id, :route_id=>User.current.routes.find_by_name(route).id,:message=>message)
            @single_message.valid_gsm_numberAPI(numbersPhone)

            @single_message.save(:validate=>false,:before_save=>false,:before_validation=>false)
            command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
            command.deliver(@single_message)
            render json: {:messsage=>"message send succesfully"}, status: 200
          else
            render json: {:message=>"The route is wrong"}, status: 404
          end
      end

      def update
           render json: {:message=> "this resource is not available"},status: 301
      end

      def destroy
        if User.current.admin
          if not SingleMessage.where(:id=>params[:id]).blank?
            @single_message=SingleMessage.where(:id=>params[:id]).first
            @single_message.destroy
            render json: {:message=>'delete single message'}, status: 200
          else
            render json: {:message=>"Not exist message with that identifier"}, status: 404
          end
        else
          render json: {:message=>"you don't have permision"}, status: 401
        end
      end
    end
  end
end
