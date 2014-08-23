require 'action_smser_utils'

class BulkMessagesController < ApplicationController

  before_action :set_bulk_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /bulk_messages
  # GET /bulk_messages.json
  def index
    @bulk_messages = BulkMessage.paginate :page => params[:page],
      :conditions => ['user_id', "%#{current_user.id}"],
      :order => 'created_at DESC',
      :per_page => 5
  end

  # GET /bulk_messages/1
  # GET /bulk_messages/1.json
  def show
  end

  # GET /bulk_messages/new
  def new
    @bulk_message = BulkMessage.new
  end

  # GET /bulk_messages/1/edit
  def edit
  end

  # POST /bulk_messages
  # POST /bulk_messages.json
  def create
    @bulk_message = BulkMessage.new(bulk_message_params)
    @bulk_message.user = current_user

    respond_to do |format|
      if @bulk_message.save
        related_numbers

        sms_list = ActionSmserUtils.generate_messages(@bulk_message, batch_size= 50)
        sms_list.each do |sms|
          sms.deliver
        end

        format.html { redirect_to @bulk_message, notice: 'Bulk message was successfully created.' }
        format.json { render :show, status: :created, location: @bulk_message }
      else
        format.html { render :new }
        format.json { render json: @bulk_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bulk_messages/1
  # PATCH/PUT /bulk_messages/1.json
  def update
    respond_to do |format|
      if @bulk_message.update(bulk_message_params)
        related_numbers
        format.html { redirect_to @bulk_message, notice: 'Bulk message was successfully updated.' }
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
      params.require(:bulk_message).permit(:message, :list_id, :route_id)
    end

    # I'm really busy to change method name
    def related_numbers
      params[:lists].each { |list_id| l = List.find(list_id);
                            @bulk_message.lists << l
                            l.gsm_numbers.each {
                              |n| @bulk_message.gsm_numbers << n if not @bulk_message.gsm_numbers.include?(n)
                            }
      }
    end
end
