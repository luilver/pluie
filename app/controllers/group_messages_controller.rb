class GroupMessagesController < ApplicationController
  before_action :set_group_message, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /group_messages
  # GET /group_messages.json
  def index
    @group_messages = current_user.group_messages
  end

  # GET /group_messages/1
  # GET /group_messages/1.json
  def show
  end

  # GET /group_messages/new
  def new
    @group_message = GroupMessage.new
  end

  # GET /group_messages/1/edit
  def edit
  end

  # POST /group_messages
  # POST /group_messages.json
  def create
    @group_message = GroupMessage.new(group_message_params)
    @group_message.user = current_user

    respond_to do |format|
      if @group_message.save
        format.html { redirect_to @group_message, notice: t('notice.item_created', item: t('activerecord.models.group_message')).html_safe }
        format.json { render :show, status: :created, location: @group_message }
      else
        format.html { render :new }
        format.json { render json: @group_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /group_messages/1
  # PATCH/PUT /group_messages/1.json
  def update
    respond_to do |format|
      if @group_message.update(group_message_params)
        format.html { redirect_to @group_message, notice: t('notice.item_updated', item: t('activerecord.models.group_message')).html_safe }
        format.json { render :show, status: :ok, location: @group_message }
      else
        format.html { render :edit }
        format.json { render json: @group_message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /group_messages/1
  # DELETE /group_messages/1.json
  def destroy
    @group_message.destroy
    respond_to do |format|
      format.html { redirect_to group_messages_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group_message
      @group_message = GroupMessage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_message_params
      params.require(:group_message).permit(:group_id, :message)
    end
end
