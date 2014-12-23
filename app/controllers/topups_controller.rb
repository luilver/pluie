class TopupsController < ApplicationController
  before_action :set_topup, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /topups
  # GET /topups.json
  def index
    @topups = Topup.paginate :page => params[:page],
      :conditions => ['user_id = ?', "#{current_user.id}"],
      :order => 'created_at DESC',
      :per_page => 5
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
    @topup = Topup.new(topup_params)
    @topup.user = current_user

    respond_to do |format|
      if @topup.save
        format.html { redirect_to @topup, notice: 'Topup was successfully created.' }
        format.json { render :show, status: :created, location: @topup }
      else
        format.html { render :new }
        format.json { render json: @topup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /topups/1
  # PATCH/PUT /topups/1.json
  def update
    respond_to do |format|
      if @topup.update(topup_params)
        format.html { redirect_to @topup, notice: 'Topup was successfully updated.' }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_topup
      @topup = Topup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topup_params
      params.require(:topup).permit(:number, :amount)
    end
end
