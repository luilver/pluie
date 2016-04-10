require 'action_smser_utils'

module Api
  module V1
    class BulkMessagesController < ApiController

      respond_to :json

      def index
        render json: {:bulk_messages=>User.current.bulk_messages.map{|bk| {:messages=>bk.message, :lists=>bk.lists.count, :numbers=>bk.receivers.count, :identifier=>bk.id }} }, status: 200
      end

      def show
        if not User.current.bulk_messages.find_by_id(params[:id]).blank?
          @bulk=User.current.bulk_messages.find_by_id(params[:id])
          render json: {:bulk_message=> {:message=>@bulk.message,:route=>@bulk.route.name,:lists=>@bulk.lists.count, :numbers=>@bulk.receivers.count, :list_names=>@bulk.lists.map{|n| n.name}}},status: 200
        else
         render json: {:message=>"Identifier (id: #{params[:id]}) invalid"}, status: 422
        end
      end

      def new
        render json: {:message=>"resources disabled"}, status: 301
      end

      def create
        route=params[:bulk_message][:route]
        return (render json: {:message=>"route is blank"}, status: 404) if route.blank?
        return (render json: {:message=>"message is blank"},status: 404) if params[:bulk_message][:message].blank?
        return (render json: {:message=>"list_names is blank"},status: 404) if params[:bulk_message][:list_names].blank?
        sm=ApplicationHelper::ManageSM.new

        if not User.current.routes.find_by_name(route).blank?
              message=params[:bulk_message][:message]
              list_names=params[:bulk_message][:list_names]
              @bulk_message=BulkMessage.new(:user_id=>User.current.id,:route_id=>User.current.routes.find_by_name(route).id,:message=>message)
              @bulk_message.lists << User.current.lists.select{|l| list_names.include?(l.name)}
              @bulk_message.url_callback=params[:url] unless params[:url].blank?

              if @bulk_message.save
              delay_options = {:queue => 'deliver'}
              job = DelayDeliveryJob.new(@bulk_message.pluie_type, @bulk_message.id, BulkDeliverer.to_s, %w(DeliveryNotifier),sm.convert_to_num(params[:from]))
              Delayed::Job.enqueue(job, delay_options)
              sm.low_cost(@bulk_message,sm.convert_to_num(params[:from]),5.minute.from_now)

              if params[:notified]
                job1 =NotifiedDeliveryReportSmsJob.new(@bulk_message.id,params[:phone_notified],BulkMessage.to_s)
                Delayed::Job.enqueue(job1,:run_at => 30.minutes.from_now)
              end

              render json: {:message=>'Send succefully',:id_sms=>@bulk_message.id.to_s+':BM'},status: 201
              else
                mens_errors=""
                @bulk_message.errors.full_messages.each do |f|
                  mens_errors=mens_errors+", "+f
                end
                render json: {:message=>mens_errors}, status: 422
              end
              else
              render json: {:message=>"Invalid route"}, status: 422
        end
      end

      def update
        render json: {:message=>"resources disabled"}, status: 301
      end

      def destroy
        return (render json: {:message=>"identifier blank"}, status: 404) if params[:id].blank?
        if User.current.admin
           if not BulkMessage.find_by_id(params[:id]).blank?
              @bulk_message=BulkMessage.find_by_id(params[:id])
              @bulk_message.destroy
              render json: {:message=>"Move permanently"},status: 301
           else
             render json: {:message=>"identifier: #{params[:id]} invalid "}, status: 422
           end
        else
          render json: {:message=>"you are not admin"}, status: 401
        end
      end
    end
  end
end
