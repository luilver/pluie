class MessagePriceCalculator
  attr_reader :receivers_counter

  def initialize(gsm_number_counter)
    @receivers_counter = gsm_number_counter
  end

  def calculate_price(record, &block)
    parts = ActionSmserUtils.sms_parts(record.message || "")
    route_price = record.route.price
    numbers_count = receivers_counter.count(record)
    block ||= ActionSmserUtils.method(:sms_cost).to_proc
    price = block.call(numbers_count, route_price, parts)
  end
end
