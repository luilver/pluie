class MessageAllController < ApplicationController
  def _index
    @single_message=SingleMessage.new
    @bulk_message=BulkMessage.new
    if params[:list_ids]
      @list_ids = params[:list_ids].map{|id| id.to_i}.to_a
    end
    respond_to do |format|
      format.html
    end
  end
end
