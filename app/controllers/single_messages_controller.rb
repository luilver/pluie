require 'action_smser_utils'

class SingleMessagesController < ApplicationController

  before_action :set_single_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /single_messages
  # GET /single_messages.json
  def index
    @single_messages = SingleMessage.paginate :page => params[:page],
      :conditions => ['user_id = ?', "#{current_user.id}"],
      :order => 'created_at DESC',
      :per_page => 5
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

    respond_to do |format|
      if @single_message.save

        MessageProcessor.deliver(@single_message, SingleDeliverer, DeliveryNotifier)

        format.html { redirect_to @single_message, notice: t('notice.sucess_msg_sent', msg: t('activerecord.models.single_message')).html_safe }
        format.json { render :show, status: :sent, location: @single_message }
      else
        format.html { render :new }
        format.json { render json: @single_message.errors, status: :unprocessable_entity }
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

    def notify_observers
      if @single_message.valid?
        message_publisher =  PluieWisper::MessagePublisher.new
        message_publisher.notify_msg_to_observers(@single_message)
      end
    end
end
