require 'action_smser_utils'

class ScheduleSmsJob
  include Wisper::Publisher

  def initialize(message,backup,random)
    @message=message
    @backup=backup
    @randomtext=random
  end

  def perform
    command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
    command.deliver(@message,@backup,@randomtext)
  end
end
