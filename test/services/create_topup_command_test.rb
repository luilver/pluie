require 'test_helper'

class CreateTopupCommandTest < ActiveSupport::TestCase

  test "creates only if user has enough balance" do
    price_calc = TopupPriceCalculator.new
    command = CreateTopupCommand.new(price_calc)
    user = User.new
    user.expects(:balance).returns(0)
    attrs = {number: "5351112345", amount: (10..50).step(5).to_a.sample}
    
    topup = command.execute(user, attrs)
    cost = price_calc.calculate_price_by_amount(attrs[:amount])
    
    assert_not topup.persisted?
    assert_includes  topup.errors.full_messages, I18n.t('errors.messages.insufficient_funds', cost: cost).html_safe

    user.expects(:balance).returns(70)
    topup = command.execute(user, attrs)

    assert topup.persisted?
    assert_equal 0, topup.errors.full_messages.size
  end
end