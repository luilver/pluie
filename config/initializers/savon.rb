require 'json'

class SavonObserver

  def notify(operation_name, builder, globals, locals)
    Rails.logger.info "Savon request: operation: #{operation_name}"
    Rails.logger.info "builder: #{builder.pretty}"
    nil
  end

end

Savon.observers << SavonObserver.new if Rails.env.development?
