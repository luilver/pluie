class GatewaysController < ApplicationController
  before_action :set_gateway, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /gateways
  # GET /gateways.json
  def index
    @gateways = Gateway.all
  end

  # GET /gateways/1
  # GET /gateways/1.json
  def show
  end

  # GET /gateways/new
  def new
    @gateway = Gateway.new
  end

  # GET /gateways/1/edit
  def edit
  end

  # POST /gateways
  # POST /gateways.json
  def create
    @gateway = Gateway.new(gateway_params)

    respond_to do |format|
      if @gateway.save
        format.html { redirect_to @gateway, notice: t('notice.item_created', item: t('activerecord.models.gateway')).html_safe }
        format.json { render :show, status: :created, location: @gateway }
      else
        format.html { render :new }
        format.json { render json: @gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gateways/1
  # PATCH/PUT /gateways/1.json
  def update
    respond_to do |format|
      if @gateway.update(gateway_params)
        format.html { redirect_to @gateway, notice: t('notice.item_updated', item: t('activerecord.models.gateway')).html_safe }
        format.json { render :show, status: :ok, location: @gateway }
      else
        format.html { render :edit }
        format.json { render json: @gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gateways/1
  # DELETE /gateways/1.json
  def destroy
    @gateway.destroy
    respond_to do |format|
      format.html { redirect_to gateways_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gateway
      @gateway = Gateway.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gateway_params
      params.require(:gateway).permit(:name, :price)
    end
end
