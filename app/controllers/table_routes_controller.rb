class TableRoutesController < ApplicationController
  before_action :set_table_route, only: [:show, :edit, :update, :destroy]

  # GET /table_routes
  # GET /table_routes.json
  def index
    #@table_routes = TableRoute.order(:created_at =>:desc).paginate(:page=>params[:page],:per_page=>5)
     @table_routes=TableRoute.search(params[:page],params[:gt_q],params[:gateway_q],params[:rt_q],params[:cc_q],params[:route_q],params[:cco_q])
  end
  # GET /table_routes/1
  # GET /table_routes/1.json
  def show
  end

  # GET /table_routes/new
  def new
    @table_route = TableRoute.new
  end

  # GET /table_routes/1/edit
  def edit
  end

  # POST /table_routes
  # POST /table_routes.json
  def create
    @table_route = TableRoute.new(table_route_params)
    id_route=params[:name_route]
    @table_route.name_route=Route.find(id_route).name if !Route.find(id_route).blank?
    @table_route.route_id=id_route

    respond_to do |format|
      if @table_route.save
        format.html { redirect_to @table_route, notice: 'New  country code route was successfully created.' }
        format.json { render :show, status: :created, location: @table_route }
      else
        format.html { render :new }
        format.json { render json: @table_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /table_routes/1
  # PATCH/PUT /table_routes/1.json
  def update
    respond_to do |format|
      id_route=params[:name_route]
      @table_route.name_route=Route.find(id_route).name if !Route.find(id_route).blank?
      @table_route.route_id=id_route
      if @table_route.update(table_route_params)
        format.html { redirect_to @table_route, notice: 'Table route was successfully updated.' }
        format.json { render :show, status: :ok, location: @table_route }
      else
        format.html { render :edit }
        format.json { render json: @table_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /table_routes/1
  # DELETE /table_routes/1.json
  def destroy
    @table_route.destroy
    respond_to do |format|
      format.html { redirect_to table_routes_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_table_route
      @table_route = TableRoute.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def table_route_params
      params.require(:table_route).permit(:name_route, :price_system, :price_cost, :country_code, :country)
    end
end
