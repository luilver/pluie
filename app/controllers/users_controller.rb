class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /users
  def index
    @users = User.order(created_at: :desc).paginate(:page => params[:page], :per_page => 10)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # GET /users/1
  def show
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.confirmed_at = Time.current
    @user.routes << Route.find_by_name('i1')
    if !user_params[:movil_number].blank?
      @user.confirm_token_number=Time.now
      @user.token_number=SecureRandom.hex(2)
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: t('notice.item_created', item: t('activerecord.models.user')).html_safe }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  def update
    if !user_params[:movil_number].blank?
      @user.confirm_token_number=Time.now
      @user.token_number=SecureRandom.hex(2)
      @user.save
    end
    if params[:api_key]=="1"
      if @user.api_key.nil?
        @user.api_setting=ApiSetting.create
      else
        @user.api_setting.reset_authentication_token!
      end
    end
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: t('notice.item_updated', item: t('activerecord.models.user')).html_safe }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path, notice: t('notice.item_removed', item: t('activerecord.models.user')).html_safe }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:balance, :email, :password, :password_confirmation, :admin, :max_debt, :locale,:low_account,:url_callback,:movil_number)
    end
end
