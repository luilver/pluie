class TopupCashier
  attr_accessor :price_strategy

  def self.default_instance
    @default ||= TopupCashier.new
  end

  def initialize(topup_price_strategy= TopupPriceCalculator.default_instance)
    @price_strategy = topup_price_strategy
  end

  def charge(topup)
    user = topup.user
    price = price_strategy.calculate_price(topup)
    if price > 0
      user.debits.create(balance: price)
      Rails.logger.info "Charged #{price} to #{user.username} for topup: #{topup}"
    end
  end
end
