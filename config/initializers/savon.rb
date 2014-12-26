require 'json'

class SavonObserver

  def notify(operation_name, builder, globals, locals)
    Rails.logger.info "Savon request: operation: #{operation_name}"
    Rails.logger.info "builder: #{builder.pretty}"
    Rails.logger.info "globals:"
    Rails.logger.info  "#{globals.inspect}"
    Rails.logger.info "locals:"
    Rails.logger.info  "#{locals.inspect}"
    nil
  end

end

Savon.observers << SavonObserver.new if Rails.env.development?
