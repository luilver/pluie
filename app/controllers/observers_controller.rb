class ObserversController < ApplicationController
  before_action :set_observer, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /observers
  # GET /observers.json
  def index
    @observers = Observer.all
  end

  # GET /observers/1
  # GET /observers/1.json
  def show
  end

  # GET /observers/new
  def new
    @observer = Observer.new
  end

  # GET /observers/1/edit
  def edit
  end

  # POST /observers
  # POST /observers.json
  def create
    @observer = Observer.new(observer_params)

    respond_to do |format|
      if @observer.save
        format.html { redirect_to @observer,notice: t('notice.item_created', item: t('activerecord.models.observer')).html_safe }
        format.json { render :show, status: :created, location: @observer }
      else
        format.html { render :new }
        format.json { render json: @observer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observers/1
  # PATCH/PUT /observers/1.json
  def update
    respond_to do |format|
      if @observer.update(observer_params)
        format.html { redirect_to @observer, notice: t('notice.item_updated', item: t('activerecord.models.observer')).html_safe }
        format.json { render :show, status: :ok, location: @observer }
      else
        format.html { render :edit }
        format.json { render json: @observer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observers/1
  # DELETE /observers/1.json
  def destroy
    @observer.destroy
    respond_to do |format|
      format.html { redirect_to observers_url, notice: t('notice.item_removed', item: t('activerecord.models.observer')).html_safe }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_observer
      @observer = Observer.find(params[:id])
      @observer.subscribe(ObserverStatusListener.default_instance)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observer_params
      params.require(:observer).permit(:number, :active)
    end
end
