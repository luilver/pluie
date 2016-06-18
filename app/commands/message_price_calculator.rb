class MessagePriceCalculator
  attr_reader :receivers_counter

  def initialize(gsm_number_counter)
    @receivers_counter = gsm_number_counter
  end

  def calculate_price(record, &block)
    parts = ActionSmserUtils.sms_parts(record.message || "")
    route_price=0
    if record.class==SingleMessage
        if record.gsm_numbers.any?
            record.gsm_numbers.each do |numbergsm|
            route_price = route_price+record.route.get_price_country_code(numbergsm.number) #number solo puede ser un solo numero (no se permite en singlemessage mas de 1 recipiente)
          end
        else
          record.valid_gsm_numbers_from_field.each do |numberV|
            route_price = route_price+record.route.get_price_country_code(numberV)
          end
        end
    else
      record.receivers.each do |number|
        route_price=route_price+record.route.get_price_country_code(number)
      end
    end

    #route_price = record.route.price
    #numbers_count = receivers_counter.count(record)
    # block ||= ActionSmserUtils.method(:sms_cost).to_proc
    # price = block.call(numbers_count, route_price, parts)
    price=route_price*parts
  end
end
