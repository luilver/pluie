require 'action_smser_utils'
require 'help_string'

class BulkMessagesController < ApplicationController
  before_action :set_bulk_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /bulk_messages
  # GET /bulk_messages.json
  def index
    @bulk_messages = BulkMessage.latest_from_user(current_user).paginate(:page => params[:page], :per_page => 5)
  end

  # GET /bulk_messages/1
  # GET /bulk_messages/1.json
  def show
  end

  # GET /bulk_messages/new
  def new
    @bulk_message = BulkMessage.new
    if params[:list_ids]
      @list_ids = params[:list_ids].map{|id| id.to_i}.to_a
    end
  end

  # GET /bulk_messages/1/edit
  def edit
  end

  # POST /bulk_messages
  # POST /bulk_messages.json
  def create
    @bulk_message = BulkMessage.new(bulk_message_params)
    @bulk_message.user = current_user
    @bulk_message.lists << List.find(params[:list_ids]) if params[:list_ids]
    sm=ApplicationHelper::ManageSM.new


    respond_to do |format|
      if @bulk_message.save

        delay_options = {:queue => 'deliver'}
        job = DelayDeliveryJob.new(@bulk_message.pluie_type, @bulk_message.id, BulkDeliverer.to_s, %w(DeliveryNotifier),sm.convert_to_num(params[:from][:from]),true)
        Delayed::Job.enqueue(job, delay_options)
        sm.low_cost(@bulk_message,sm.convert_to_num(params[:from][:from]),5.minute.from_now)

        if params[:notified][:notified].to_s.to_bool and !@bulk_message.user.confirm_token_number.blank?
          job1 =NotifiedDeliveryReportSmsJob.new(@bulk_message.id,@bulk_message.user.movil_number,BulkMessage.to_s)
          time_notified=@bulk_message.receivers.count <= 2500 ? 30.minutes.from_now : 46.minutes.from_now
          Delayed::Job.enqueue(job1,:run_at => time_notified)
        end unless params[:notified].nil?

        format.html { redirect_to @bulk_message, notice: t('notice.sucess_msg_sent', msg: t('activerecord.models.bulk_message')).html_safe}
        format.json { render :show, status: :created, location: @bulk_message }
      else
          if current_user.unit_views
            @single_message=SingleMessage.new
            format.html { render 'message_all/_index' }
          else
            format.html {render :new}
            format.json { render json: @bulk_message.errors, status: :unprocessable_entity }
          end
      end
    end
  end

  # PATCH/PUT /bulk_messages/1
  # PATCH/PUT /bulk_messages/1.json
  def update
    respond_to do |format|
      if @bulk_message.update(bulk_message_params)
        format.html { redirect_to @bulk_message, notice: t('notice.sucess_msg_resent', msg: t('activerecord.models.bulk_message')).html_safe }
        format.json { render :show, status: :ok, location: @bulk_message }
      else
        format.html { render :edit }
        format.json { render json: @bulk_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bulk_messages/1
  # DELETE /bulk_messages/1.json
  def destroy
    @bulk_message.destroy
    respond_to do |format|
      format.html { redirect_to bulk_messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bulk_message
      @bulk_message = BulkMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bulk_message_params
      params.require(:bulk_message).permit(:message, :route_id)
    end
end
