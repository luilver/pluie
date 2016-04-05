class LowBalanceUserJob
  include Wisper::Publisher

  def initialize(message,number_from,balance_old)
    @message=message
    @number_from=number_from
    @balance_old=balance_old
  end

  def perform
    if @message.user.low_account.to_f > @message.user.balance.to_f and !@message.user.confirm_token_number.nil? and @message.user.low_account.to_f < @balance_old.to_f
      sm =SingleMessage.new
      sm.message=I18n.translate('notice.low_balance',:username=>@message.user.username,:balance=>@message.user.balance)
      sm.route=@message.user.routes.order(:price=>:asc).first
      sm.user=@message.user
      sm.number=@message.user.movil_number
      if sm.save
        command = DeliverMessage.new(SingleDeliverer, DeliveryNotifier)
        command.deliver(sm,true,true,@number_from)
      end
    end
  end
end
