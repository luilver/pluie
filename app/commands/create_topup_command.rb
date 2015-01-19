class CreateTopupCommand
  include Wisper::Publisher

  def initialize(price_strategy)
    @price_strategy = price_strategy
  end

  def execute(user, attributes)
    topup = Topup.new(attributes)
    topup.user = user
    if validate_and_save_record(topup)
      publish(:success, topup)
    else
      publish(:failure, topup)
    end
    topup
  end

  private
    def validate_and_save_record(topup)
      cost = @price_strategy.calculate_price(topup)
      unless has_funds = topup.user.balance >= cost
        topup.errors[:base] << I18n.t('errors.messages.insufficient_funds', cost: cost).html_safe
      end
      has_funds && topup.save
    end
end
