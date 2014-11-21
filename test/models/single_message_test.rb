require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase

  setup do
    @one = single_messages(:one)
    @numbers = []
    5.times{ |i| @numbers << cubacel_random_number }
  end

  test "should have message" do
    sm = SingleMessage.random
    assert_not sm.message.blank?
  end

  test "should have number" do
    sm = SingleMessage.random
    assert_not sm.number.blank?
  end

  test "receivers with multiple numbers" do
    @one.number = @numbers.join(" ")
    @numbers.each do |num|
      assert_includes @one.receivers, num
    end
  end

  test "gsm_numbers_count equals receivers count" do
    assert_equal @one.receivers.count, @one.gsm_numbers_count
    @one.number = @numbers.join(" ")
    assert_equal @one.receivers.count, @one.gsm_numbers_count
  end

end
