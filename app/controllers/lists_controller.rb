class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource except: [:create]

  # GET /lists
  # GET /lists.json
  def index
    @lists  = List.where(user: current_user).paginate(:page => params[:page], :per_page => 5)
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  # POST /lists.json
  def create
    @list = List.new(list_params)
    @list.user = current_user
    @list.gsm_numbers << GsmNumber.find_or_create_by(:number=>params[:number_list]) if !params[:number_list].blank?

    respond_to do |format|
      if @list.save
        @list.delay.attach_numbers
        format.html { redirect_to @list, notice: t('notice.item_created_fm', item: t('activerecord.models.list')).html_safe   }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  def update
    respond_to do |format|
      if @list.update(list_params)
        if params[:remove]
          @list.delay.remove_numbers
        else
          @list.delay.attach_numbers
        end

        @list.gsm_numbers << GsmNumber.find_or_create_by(:number=>params[:number_list]) if !params[:number_list].blank? and @list.gsm_numbers.where(:number=>params[:number_list]).blank?
        format.html { redirect_to @list, notice: t('notice.item_updated_fm', item: t('activerecord.models.list')).html_safe   }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_url, notice: t('notice.item_removed_fm', item: t('activerecord.models.list')).html_safe }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def list_params
      params.require(:list).permit(:name, :file)
    end
end
