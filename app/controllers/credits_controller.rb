class CreditsController < ApplicationController
  before_action :set_credit, only: [:show, :edit, :update, :destroy]
  after_action :credit_user, only: [:create]
  load_and_authorize_resource except: [:create]

  # GET /credits
  # GET /credits.json
  def index
    @credits = Credit.paginate :page => params[:page],
      :conditions => ['user_id = ?', "#{current_user.id}"],
      :order => 'created_at DESC',
      :per_page => 5
    @credits = Credit.paginate :page => params[:page],
      :order => 'created_at DESC',
      :per_page => 5 if current_user.admin
  end

  # GET /credits/1
  # GET /credits/1.json
  def show
  end

  # GET /credits/new
  def new
    @credit = Credit.new
  end

  # GET /credits/1/edit
  def edit
  end

  # POST /credits
  # POST /credits.json
  def create
    @credit = Credit.new(credit_params)
    relate_user

    respond_to do |format|
      if @credit.save
        format.html { redirect_to @credit, notice: 'Credit was successfully created.' }
        format.json { render :show, status: :created, location: @credit }
      else
        format.html { render :new }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /credits/1
  # PATCH/PUT /credits/1.json
  def update
    respond_to do |format|
      if @credit.update(credit_params)
        format.html { redirect_to @credit, notice: 'Credit was successfully updated.' }
        format.json { render :show, status: :ok, location: @credit }
      else
        format.html { render :edit }
        format.json { render json: @credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1
  # DELETE /credits/1.json
  def destroy
    @credit.destroy
    respond_to do |format|
      format.html { redirect_to credits_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit
      @credit = Credit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def credit_params
      params.require(:credit).permit(:balance)
    end

    def relate_user
      @credit.user = User.find(params[:user])
    end

    def credit_user
      @credit.user.balance += @credit.balance
      @credit.save
    end
end
