require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase
  should validate_presence_of :route
  should validate_presence_of :message
  should validate_presence_of :number

  setup do
    @one = single_messages(:one)
    @one.save # triggers callback to store gsm numbers
    @numbers =  cubacel_numbers(5)
    stub_request_for_async_test
  end

  test "receivers with multiple numbers" do
    change_number_field(@one, @numbers)
    @numbers.each do |num|
      assert_includes @one.receivers, num
    end
  end

  test "gsm_numbers_count equals receivers count" do
    assert_equal @one.receivers.count, @one.gsm_numbers_count
    change_number_field(@one, @numbers)
    assert_equal @one.receivers.count, @one.gsm_numbers_count
  end

  test "creates DLR and charge to user" do
    id = @one.user.id
    change_number_field(@one, @numbers)
    c = @one.receivers.count

    assert_difference 'ActionSmser::DeliveryReport.count', c  do
      assert_message_is_charged(@one, SingleDeliverer)
    end
  end

  test "gsm_numbers equivalent to receivers" do
    gsm_numbers_equals_receivers(@one)
    nums = cubacel_numbers(10)
    change_number_field(@one, nums)
    gsm_numbers_equals_receivers(@one)
  end

  def gsm_numbers_equals_receivers(msg)
    gsm_nums = msg.gsm_numbers.map { |gsm| gsm.number  }
    gsm_nums.each do |gsm|
      assert_includes msg.receivers, gsm, "Gsm number not in receiver"
    end
    msg.receivers.each do |num|
      assert_includes gsm_nums, num, "Receiver number not in gsm_numbers"
    end
  end

  def change_number_field(msg, numbers)
    msg.number = numbers.join(" ")
    msg.save
  end
end
