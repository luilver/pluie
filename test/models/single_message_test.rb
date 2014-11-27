require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase

  setup do
    @one = single_messages(:one)
    @numbers = []
    Random.new.rand(2..5).times { |i| @numbers << cubacel_random_number }
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
    fix_users_credit
  end

  test "should have message" do
    sm = SingleMessage.choose_random
    assert_not sm.message.blank?
  end

  test "should have number" do
    sm = SingleMessage.choose_random
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

  test "creates DLR" do
    assert_difference 'ActionSmser::DeliveryReport.count' do
      @one.deliver
    end
    assert_difference 'ActionSmser::DeliveryReport.count', @numbers.size do
      @one.number = @numbers.join(" ")
      @one.deliver
    end
  end

  test "generates debits when sending" do
    assert_difference 'Debit.count' do
      @one.deliver
    end
  end

  test "charge after deliver" do
    expected = @one.message_cost
    id = @one.user.id
    @two = single_messages(:two)
    @two.number = @numbers.join(" ")
    expected += @two.message_cost
    assert_difference 'User.find(id).balance', -expected do
      @one.deliver
      @two.deliver
    end
  end
end
