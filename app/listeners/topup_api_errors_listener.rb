class TopupApiErrorsListener
  def initialize(logger=Rails.logger)
    @logger = logger
  end

  def topup_api_error(msg)
    @logger.error "Topup_api_error:"
    log_error(msg)
  end

  def failed_topup_api_operation(operation, msg)
    @logger.error "Topup_api_operation_failed: #{operation}"
    log_error(msg)
  end

  private
    def log_error(msg)
      @logger.error "date: #{Time.current}, msg: #{msg}"
    end
end
