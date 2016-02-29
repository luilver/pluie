require 'action_smser_utils'

class SingleMessagesController < ApplicationController
  before_action :set_single_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /single_messages
  # GET /single_messages.json
  def index
    @single_messages = SingleMessage.latest_from_user(current_user).paginate(:page => params[:page], :per_page => 5)
  end

  # GET /single_messages/1
  # GET /single_messages/1.json
  def show
  end

  # GET /single_messages/new
  def new
    @single_message = SingleMessage.new
  end

  # GET /single_messages/1/edit
  def edit
  end

  # POST /single_messages
  # POST /single_messages.json
  def create
    @single_message = SingleMessage.new(single_message_params)
    @single_message.user = current_user

    sm =ApplicationHelper::ManageSM.new

    respond_to do |format|
      if params['schedule']['schedule'].to_i==1
        time=sm.convertTodate(params['datepik']['datepik'],params['date']) #objeto de tipo Time
           if sm.check_time(time)
              if  @single_message.save
                ApplicationHelper::ManageSM.schedule_job(@single_message,sm.validate_backup(params[:backupSms]),sm.validate_rt(params[:randomText]),time)
                format.html { redirect_to @single_message, notice: t('notice.success_schedule_sent',time:time, msg: t('activerecord.models.single_message')).html_safe  }
                format.json { render :show, status: :sent, location: @single_message }
              else
                format.html { render :new }
                format.json { render json: @single_message.errors, status: :unprocessable_entity }
              end
           else
             @single_message.errors[t('errors.messages.datetime_name')]= t('errors.messages.incorrect_datetime') if time.class!=Time
             @single_message.errors[t('errors.messages.date_notice')]= t('errors.messages.date_old') if time.class==Time and time < Time.now
             format.html { render :new }
             format.json { render json: @single_message.errors, status: :unprocessable_entity }
           end
      else
          if @single_message.save
              sm.send_message_simple(@single_message,sm.validate_backup(params[:backupSms]),sm.validate_rt(params[:randomText]))
              format.html { redirect_to @single_message, notice: t('notice.sucess_msg_sent', msg: t('activerecord.models.single_message')).html_safe }
              format.json { render :show, status: :sent, location: @single_message }
          else
            format.html { render :new }
            format.json { render json: @single_message.errors, status: :unprocessable_entity }
          end
      end
    end
  end

  # PATCH/PUT /single_messages/1
  # PATCH/PUT /single_messages/1.json
  def update
    respond_to do |format|
      if @single_message.update(single_message_params)

        format.html { redirect_to @single_message, notice: t('notice.sucess_msg_resent', msg: t('activerecord.models.single_message')).html_safe }
        format.json { render :show, status: :ok, location: @single_message }
      else
        format.html { render :edit }
        format.json { render json: @single_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /single_messages/1
  # DELETE /single_messages/1.json
  def destroy
    @single_message.destroy
    respond_to do |format|
      format.html { redirect_to single_messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_single_message
      @single_message = SingleMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def single_message_params
      params.require(:single_message).permit(:message, :number, :route_id)
    end

    def convertTodate(date,time)
      day,month,year=date.split("/")
      #Time.new(date["year"].to_i,date["month"].to_i,date["day"].to_i,date["hour"].to_i,date["minute"].to_i,)
      begin
      Time.new(year.to_i,month.to_i,day.to_i,time['hour'].to_i, time['minute'].to_i)
      rescue
        return nil
      end
      end
end
