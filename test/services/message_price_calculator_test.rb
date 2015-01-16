require 'test_helper'

class MessagePriceCalculatorTest < ActiveSupport::TestCase
  setup do
    @msg_mock = mock()
    route = mock()
    route.expects(:price).returns(0.5).at_least_once
    @msg_mock.expects(:route).returns(route)
    @msg_mock.expects(:message).returns("some text in message")
    @receivers_counter = mock()
    @receivers_counter.expects(:count).returns(5)
  end

  test "allows alternative price strategy" do
    calc = MessagePriceCalculator.new(@receivers_counter)
    price = calc.calculate_price(@msg_mock) do |num_count, route_price, parts|
      assert_equal 5, num_count
      assert_equal 0.5, route_price
      assert_equal 1, parts
      50
    end
    assert_equal 50, price
  end

  test "calculate_price" do
    assert_equal 2.5, MessagePriceCalculator.new(@receivers_counter).calculate_price(@msg_mock)
  end

end
