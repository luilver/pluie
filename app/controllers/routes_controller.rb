class RoutesController < ApplicationController
  before_action :set_route, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /routes
  # GET /routes.json
  def index
    @routes = Route.order(created_at: :desc).paginate(:page => params[:page], :per_page => 5)
  end

  # GET /routes/1
  # GET /routes/1.json
  def show
  end

  # GET /routes/new
  def new
    @route = Route.new
  end

  # GET /routes/1/edit
  def edit
  end

  # POST /routes
  # POST /routes.json
  def create
    if params[:nil_user]=="1"
     params[:route].delete(:user_id)
    end
    @route = Route.new(route_params)
    @route.users << User.find(route_params[:user_id]) unless params[:nil_user]=="1"

    respond_to do |format|
      if @route.save
        format.html { redirect_to @route, notice: t('notice.item_created_fm', item: t('activerecord.models.route')).html_safe  }
        format.json { render :show, status: :created, location: @route }
      else
        format.html { render :new }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /routes/1
  # PATCH/PUT /routes/1.json
  def update
    respond_to do |format|

       if params[:add_user]=="1"
         @route.users << User.find(route_params[:user_id]) unless !@route.users.select{|y| y.id == route_params[:user_id]}.blank?
       end

      if params[:remove_user]=="1"
        @route.users.destroy(params[:remove_id])
      end

      route_params.delete(:user_id)
      if @route.update(route_params)
        format.html { redirect_to @route, notice: t('notice.item_updated_fm', item: t('activerecord.models.route')).html_safe  }
        format.json { render :show, status: :ok, location: @route }
      else
        format.html { render :edit }
        format.json { render json: @route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /routes/1
  # DELETE /routes/1.json
  def destroy
    @route.destroy
    respond_to do |format|
      format.html { redirect_to routes_url, notice: t('notice.item_removed_fm', item: t('activerecord.models.route')).html_safe }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_route
      @route = Route.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
      params.require(:route).permit(:name, :price, :user_id, :gateway_id, :system_route)
    end
end
