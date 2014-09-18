class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @users = User.paginate :page => params[:page],
      :order => 'created_at DESC',
      :per_page => 10
  end

  # DELETE /credits/1
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_path }
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
      params.require(:user).permit(:balance)
    end
end
