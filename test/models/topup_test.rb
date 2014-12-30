require 'test_helper'

class TopupTest < ActiveSupport::TestCase
  should validate_presence_of :number
  should allow_value(cubacel_random_number).for(:number)
  should_not allow_value("54021461").for(:number)

  setup do
    @api_client = TopupApiService.new
    @api_client.stubs(:current_ticket).returns("ticket")
    @api_client.subscribe(TopupCashier.new,  on: :topup_api_recharge_success, with: :charge)
  end

  test "should charge topups to user" do
    u = users(:two)
    topups = u.topups
    price_strategy = TopupCashier.new.price_strategy
    total_price = topups.to_a.reduce(0) { |sum, t| sum + price_strategy.calculate_price(t)  }
    @api_client.stubs(:call_and_fail_gracefully).returns({code: 1, message: "recarga exitosa"})
    assert_differences [['User.find(u.id).balance', -total_price], ['User.find(u.id).debits.count', topups.count]] do
      @api_client.recharge(topups)
    end
  end

  test "should not charge failed topups" do
    topup = topups(:one)
    user_id = topup.user.id
    @api_client.stubs(:call_and_fail_gracefully).returns({code: 0, message: "service unavailable"})
    assert_difference ['User.find(user_id).balance', 'User.find(user_id).debits.count'], 0 do
      @api_client.recharge(topups)
    end
  end
end
