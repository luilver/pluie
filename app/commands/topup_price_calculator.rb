class TopupPriceCalculator
  attr_reader :pluie_fee, :fixed_prices

  def self.default_instance
    @default ||= TopupPriceCalculator.new
  end

  def initialize(prices= {}, pluie_fee= 1.1)
    @fixed_prices = (((10..50).step(5).map { |a| [ a, a * pluie_fee] }).to_h).merge(prices)
    @fixed_prices.freeze
    @pluie_fee = pluie_fee
  end

  def calculate_price(topup)
    amount = topup.amount
    fixed_prices[amount] || amount * pluie_fee
  end
end
