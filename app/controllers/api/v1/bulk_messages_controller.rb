require 'action_smser_utils'

module Api
  module V1
    class BulkMessagesController < ApiController

      respond_to :json

      def index
        render json: {:bulk_messages=>User.current.bulk_messages.map{|bk| {:messages=>bk.message, :lists=>bk.lists.count, :numbers=>bk.receivers.count, :identifier=>bk.id }} }
      end

      def show
        if not User.current.bulk_messages.find_by_id(params[:id]).blank?
          @bulk=User.current.bulk_messages.find_by_id(params[:id])
          render json: {:bulk_message=> {:message=>@bulk.message,:route=>@bulk.route.name,:lists=>@bulk.lists.count, :numbers=>@bulk.receivers.count, :list_names=>@bulk.lists.map{|n| n.name}}},status: 200
        else
         render json: {:message=>"Not exists bulk message with that id"}, status: 404
        end
      end

      def new
        render json: {:message=>"not exists this resources"}, status: 301
      end

      def create
        route=params[:bulk_message][:route]
        if not User.current.routes.find_by_name(route).blank?
              message=params[:bulk_message][:message]
              list_names=params[:bulk_message][:list_names]
              @bulk_message=BulkMessage.new(:user_id=>User.current.id,:route_id=>User.current.routes.find_by_name(route).id,:message=>message)
              @bulk_message.lists << User.current.lists.select{|l| list_names.include?(l.name)}

              if @bulk_message.save
              delay_options = {:queue => 'deliver'}
              job = DelayDeliveryJob.new(@bulk_message.pluie_type, @bulk_message.id, BulkDeliverer.to_s, %w(DeliveryNotifier))
              Delayed::Job.enqueue(job, delay_options)
              render json: {:message=>'El Envío masivo fue iniciado satisfactoriamente'},status: 200
              else
                render json: @bulk_message.errors, status: 402
              end
              else
              render json: {:message=>"You don't have this route"}, status: 404
        end
      end

      def update
        respond_with BulkMessage.update(params[:id], params[:bulk_message])
      end

      def destroy
        if User.current.admin
           if not BulkMessage.find_by_id(params[:id]).blank?
              @bulk_message=BulkMessage.find_by_id(params[:id])
              @bulk_message.destroy
              render json: {:message=>"Move permanently"},status: 301
           else
             render json: {:message=>"Not exists bulk message with that id"}, status: 404
           end
        else
          render json: {:message=>"you don't have permision"}, status: 401
        end
      end
    end
  end
end
