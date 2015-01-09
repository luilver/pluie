require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase
  should validate_presence_of :route
  should validate_presence_of :message
  should validate_presence_of :number

  setup do
    @one = single_messages(:one)
    @count = 5
    @numbers = cubacel_numbers(@count)
  end

  test "should calculate message price" do
    route_price = @one.route.price
    init_price = ActionSmserUtils.sms_cost(1, route_price, 1)
    assert_equal init_price, @one.message_cost

    change_number_field(@one, @numbers)
    price = ActionSmserUtils.sms_cost(@count, route_price, 1)
    assert_equal price, @one.message_cost
  end

  test "receivers with multiple numbers" do
    change_number_field(@one, @numbers)
    receivers = @one.receivers
    @numbers.each do |num|
      assert_includes receivers, num
    end
  end

  test "creates DLR and charge to user" do
    stub_request_for_async_test
    id = @one.user.id
    change_number_field(@one, @numbers)

    assert_difference 'ActionSmser::DeliveryReport.count',@count  do
      assert_message_is_charged(@one, SingleDeliverer)
    end
  end

  test "gsm_numbers equivalent to receivers" do
    @one.save
    gsm_numbers_equals_receivers(@one)
    change_number_field(@one, @numbers)
    gsm_numbers_equals_receivers(@one)
  end

  def gsm_numbers_equals_receivers(msg)
    gsm_nums = msg.gsm_numbers.pluck(:number)
    receivers = msg.receivers
    gsm_nums.each do |gsm|
      assert_includes receivers, gsm, "Gsm number not in receiver"
    end
    receivers.each do |num|
      assert_includes gsm_nums, num, "Receiver number not in gsm_numbers"
    end
  end

  def change_number_field(msg, numbers)
    msg.number = numbers.join(" ")
    msg.save
  end
end
