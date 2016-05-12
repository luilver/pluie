class PrefixController < ApplicationController

  def new
    @prefix_t = PrefixTable.new
  end

  def show
  end

  def create
   @prefix_t=PrefixTable.new(:country_code=>params[:prefix],:country=>params[:country])
   if @prefix_t.save
      render 'show'
   else
      render 'new'
   end
  end

end
