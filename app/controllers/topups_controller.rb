class TopupsController < ApplicationController
  before_action :set_topup, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /topups
  # GET /topups.json
  def index
    @topups = Topup.latest_from_user(current_user).paginate(page: params[:page], per_page: 5)
  end

  # GET /topups/1
  # GET /topups/1.json
  def show
  end

  # GET /topups/new
  def new
    @topup = Topup.new
  end

  # GET /topups/1/edit
  def edit
  end

  # POST /topups
  # POST /topups.json
  def create
    create_topup_service.on(:success) do |topup|
      @topup = topup
      respond_to do |format|
        format.html { redirect_to @topup, notice: t('notice.item_created_fm', item: Topup.model_name.human.html_safe)}
        format.json { render :show, status: :created, location: @topup }
      end
    end
    create_topup_service.on(:failure) do |topup|
      @topup = topup
      respond_to do |format|
        format.html { render :new }
        format.json { render json: topup.errors, status: :unprocessable_entity }
      end
    end
    create_topup_service.subscribe(recharge_listener, async: true, on: :success, with: :recharge )
    create_topup_service.execute(current_user, topup_params)
  end

  # PATCH/PUT /topups/1
  # PATCH/PUT /topups/1.json
  def update
    respond_to do |format|
      if @topup.update(topup_params)
        format.html { redirect_to @topup, notice: t('notice.item_updated_fm', item: Topup.model_name.human.html_safe) }
        format.json { render :show, status: :ok, location: @topup }
      else
        format.html { render :edit }
        format.json { render json: @topup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topups/1
  # DELETE /topups/1.json
  def destroy
    @topup.destroy
    respond_to do |format|
      format.html { redirect_to topups_url }
      format.json { head :no_content }
    end
  end

  private
    def recharge_listener
      unless @recharge_listener
        @recharge_listener = TopupApiService.new
        @recharge_listener.subscribe(topup_cashier,  on: :topup_api_recharge_success, with: :charge)
      end
      @recharge_listener
    end

    def create_topup_service
      @create_topup_service ||= CreateTopupCommand.new(topup_cashier.price_strategy)
    end

    def topup_cashier
      @cashier ||= TopupCashier.new
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_topup
      @topup = Topup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topup_params
      params.require(:topup).permit(:number, :amount)
    end
end
