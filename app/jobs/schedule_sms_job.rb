require 'action_smser_utils'

class ScheduleSmsJob
  include Wisper::Publisher

  def initialize(message,backup,random,number_from)
    @message=message
    @backup=backup
    @randomtext=random
    @number_from=number_from
  end

  def perform
    command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
    command.deliver(@message,@backup,@randomtext,@number_from)
  end
end
