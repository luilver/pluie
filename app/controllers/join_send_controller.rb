class JoinSendController < ApplicationController
  before_filter :validate_unit_view

  def index
  end

  def new
   @errors= params[:error]||= []
  end

  def show
    @params_send=params[:params_send] ||= {:message=>"",:route=>"",:lists=>"",:numbers=>""}
  end

  def create
    sm=ApplicationHelper::ManageSM.new
    @errors=[]
    @remintente = params[:remitente]
    @lists_ids =params[:list_ids]
    @number=params[:number]
    @message=params[:message_join]
    @route_id=params[:route_id]

    if !validates_field
      redirect_to join_send_new_path(:error=>@errors, :message_join=>@message,:route_id=>@route_id)
    else
      params_send={:message=> @message, :route_id=>@route_id}
      if !@lists_ids.blank?
        @bulk_message = BulkMessage.new(params_send)
        @bulk_message.user = current_user
        @bulk_message.lists << List.find(params[:list_ids]) if params[:list_ids]
          if @bulk_message.save
            delay_options = {:queue => 'deliver'}
            job = DelayDeliveryJob.new(@bulk_message.pluie_type, @bulk_message.id, BulkDeliverer.to_s, %w(DeliveryNotifier),sm.convert_to_num(@remintente))
            Delayed::Job.enqueue(job, delay_options)
        end
      end
      if @number.present?
        @single_message = SingleMessage.new(params_send)
        @single_message.number=@number
        @single_message.user = current_user
        if @single_message.save
          sm.send_message_simple(@single_message,false,true,sm.convert_to_num(@remintente))
        end
      end
      redirect_to join_send_show_path(:params_send=>{:message=>@message,:route=>Route.find(@route_id.to_i).name,:lists=>@lists_ids,:numbers=>@number})
    end
    end

  def validates_field
    @errors << {:name =>"list or number not be empty"} if @number.blank? and @lists_ids.blank?
    @errors << {:name => "message not be empty"} if @message.blank?
    @errors << {:name =>"route no be empty"} if @route_id.blank?
    if @errors.count > 0
      return false
    end
    return true
  end

  protected
   def validate_unit_view
     if !current_user.unit_views
         redirect_to root_path
     end
   end

end
