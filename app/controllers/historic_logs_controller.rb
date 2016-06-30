class HistoricLogsController < ApplicationController
  before_action :set_historic_log, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  respond_to :html

  def index
    @historic_logs = HistoricLog.all
    respond_with(@historic_logs)
  end

  def show
    respond_with(@historic_log)
  end

  def new
    @historic_log = HistoricLog.new
    respond_with(@historic_log)
  end

  def edit
  end

  def create
    @historic_log = HistoricLog.new(historic_log_params)
    flash[:notice] = 'HistoricLog was successfully created.' if @historic_log.save
    respond_with(@historic_log)
  end

  def update
    flash[:notice] = 'HistoricLog was successfully updated.' if @historic_log.update(historic_log_params)
    respond_with(@historic_log)
  end

  def destroy
    @historic_log.destroy
    respond_with(@historic_log)
  end

  private
    def set_historic_log
      @historic_log = HistoricLog.find(params[:id])
    end

    def historic_log_params
      params.require(:historic_log).permit(:action_name, :controller_name, :user_id)
    end
end
