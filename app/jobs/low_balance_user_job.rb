class LowBalanceUserJob
  include Wisper::Publisher

  def initialize(message)
    @message=message
  end

  def perform
    if @message.user.low_account.to_f > @message.user.balance.to_f and !@message.user.confirm_token_number.nil?
      sm =SingleMessage.new
      sm.message=I18n.translate('notice.low_balance',:username=>@message.user.username,:balance=>@message.user.balance)
      sm.route=@message.user.routes.order(:price=>:asc).first
      sm.user=@message.user
      sm.number=@message.user.movil_number
      if sm.save
        command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
        command.deliver(sm,false,true)
      end
    end
  end
end