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
          render json: {:message=>"invalid indentifier: #{params[:id]}"}, status: 422
        end
      end

      def new
          render json: {:message=> "resource disabled"},status: 301
      end

      def create
          numbersPhone=params[:single_message][:numbers]
          route=params[:single_message][:route]
          message=params[:single_message][:message]
          

          return (render json: {:message=>"route is blank"},status: 404) if route.blank?
          return (render json: {:message=>"message is blank"},status: 404) if message.blank?
          if not User.current.routes.find_by_name(route).blank?
            @single_message=SingleMessage.new(:user_id=>User.current.id, :route_id=>User.current.routes.find_by_name(route).id,:message=>message)
            #@single_message.valid_gsm_numberAPI(numbersPhone)
            @single_message.number=numbersPhone.join(" ")

            if  !params[:single_message][:scheduleSms].blank? and params[:single_message][:scheduleSms]
               if !params[:single_message][:date].blank?
                 time=validate_datetime(params[:single_message][:date])
                 if time.class == Time
                   if time >=Time.now
                     if @single_message.save
                       job=ScheduleSmsJob.new(@single_message,params[:single_message][:backupSms],
                                              params[:single_message][:randomText])
                       ApplicationHelper::ScheduleUtils.schedule(job,time)
                       render json: {:messsage=>t('notice.success_schedule_sent',time:time,msg: t('activerecord.models.single_message'))}, status: 200
                     else
                       mens_errors=""
                       @single_message.errors.full_messages.each do |f|
                          mens_errors=mens_errors+", "+f
                       end
                       render json: {:message=>mens_errors}, status: 422
                     end
                   else
                     render json: {:message=> t('errors.messages.date_notice') +  t('errors.messages.date_old')}
                   end
                 else
                   render json: {:ok=>t('errors.messages.datetime_name') + t('errors.messages.incorrect_datetime')}
                 end
               else
                 render json: {:message=>'date is blank'}
               end
            else
              if @single_message.save
              command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
              command.deliver(@single_message,params[:single_message][:backupSms],
                             params[:single_message][:randomText])
              render json: {:messsage=>"Single Message successfully sent"}, status: 200
              else
                mens_errors=""
                @single_message.errors.full_messages.each do |f|
                   mens_errors=mens_errors+", "+f
                end
                render json: {:message=>mens_errors}, status: 422
              end
            end
          else
            render json: {:message=>"Invalid route"}, status: 422
          end
      end

      def update
           render json: {:message=> "resources disabled"},status: 301
      end

      def destroy
        if User.current.admin
          if not SingleMessage.where(:id=>params[:id]).blank?
            @single_message=SingleMessage.where(:id=>params[:id]).first
            @single_message.destroy
            render json: {:message=>'removed single message succefully'}, status: 301
          else
            render json: {:message=>"invalid identifier: #{params[:id]}"}, status: 422
          end
        else
          render json: {:message=>"permission denied"}, status: 401
        end
      end

      private

      def validate_datetime(datetime)
        begin
          Time.new(datetime[:year],datetime[:month],datetime[:day],datetime[:hour],datetime[:minute])
        rescue
          return false
        end
      end
    end
  end
end
