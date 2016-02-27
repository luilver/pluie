class LowBalanceUserJob
  include Wisper::Publisher

  def initialize(message)
    @message=message
  end

  def perform
    if ApplicationHelper::TOPUP > @message.user.balance
      sm =SingleMessage.new
      sm.message=I18n.translate('notice.low_balance',:username=>@message.user.username,:balance=>@message.user.balance)
      sm.route=User.where(:admin=>true,:email=>'admin@openbgs.com').first.routes.first
      sm.user=User.where(:admin=>true,:email=>'admin@openbgs.com').first
      sm.number="5354567519"
      if sm.save
        command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
        command.deliver(sm,false,true)
      end
    end
  end
end