class PrefixController < ApplicationController

  def index
    @prefix_all  = PrefixTable.paginate(:page => params[:page], :per_page => 5)
  end

  def new
    @prefix_t = PrefixTable.new
  end

  def edit
    @prefix_t=PrefixTable.find(params[:id])
  end

  def show
    @prefix_t=PrefixTable.find(params[:id])
  end

  def create
   @prefix_t=PrefixTable.new(:country_code=>params[:prefix],:country=>params[:country])
   if @prefix_t.save
      render 'show'
   else
      render 'new'
   end
  end

  def update
    @prefix_t= PrefixTable.find(params[:id])
    @prefix_t.country_code=params[:prefix]
    @prefix_t.country=params[:country]
    if @prefix_t.save
      render 'show'
    else
      render 'edit'
    end
  end

  def destroy
    @prefix_t=PrefixTable.find(params[:id])
    @prefix_t.destroy
    redirect_to prefix_path
  end
end
