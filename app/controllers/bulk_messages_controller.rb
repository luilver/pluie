class BulkMessagesController < ApplicationController
  before_action :set_bulk_message, only: [:show, :edit, :update, :destroy]

  # GET /bulk_messages
  # GET /bulk_messages.json
  def index
    @bulk_messages = BulkMessage.all
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

    respond_to do |format|
      if @bulk_message.save
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
      params.require(:bulk_message).permit(:message, :list_id)
    end
end
