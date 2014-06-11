class SingleMessagesController < ApplicationController
  before_action :set_single_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]
  include SmsApi

  # GET /single_messages
  # GET /single_messages.json
  def index
    @single_messages = current_user.single_messages
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
        related_numbers
        format.html { redirect_to @single_message, notice: 'Single message was successfully created.' }
        format.json { render :show, status: :created, location: @single_message }
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
        related_numbers
        format.html { redirect_to @single_message, notice: 'Single message was successfully updated.' }
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
      params.require(:single_message).permit(:message, :number)
    end

    def related_numbers
      @single_message.number.split.each { |num| n = GsmNumber.find_by_number(num) ||
                                          GsmNumber.create(:number => num);
                                          @single_message.gsm_numbers << n if not @single_message.gsm_numbers.include?(n)
      }
    end
end
