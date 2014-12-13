require 'test_helper'

class BulkMessageTest < ActiveSupport::TestCase
  should validate_presence_of :lists
  should validate_presence_of :route
  should validate_presence_of :message

  setup do
    stub_request_for_async_test
  end

  test "creates msg only if user has balance to paid" do
    r = routes(:expensive)
    list = lists(:one)
    list.stubs(:receivers).returns(cubacel_numbers(50))
    bm = bulk_messages(:one)
    bm.route = r
    bm.lists << list
    assert bm.invalid?

    bm2 = bulk_messages(:bulk)
    list.update(user: bm2.user)
    bm2.lists << list
    assert bm2.valid?
  end

  test "should create DLRs and charge cost to user" do
    list = lists(:two)
    numbers = Set.new(cubacel_numbers(300)).to_a
    list.stubs(:receivers).returns(numbers)
    bm = bulk_messages(:bulk)
    bm.lists << list

    assert_difference 'ActionSmser::DeliveryReport.count', 300  do
      assert_message_is_charged(bm, BulkDeliverer)
    end
  end

  test "should send from multiple lists" do
    bm = bulk_messages(:multi_lists)
    bm.lists.each {|l| l.stubs(:receivers).returns(cubacel_numbers(3))}
    assert_message_is_charged(bm, BulkDeliverer)
  end

  test "should not repeat numbers from lists" do
    bm = bulk_messages(:bulk)
    lists = generate_collection(4) {List.new(user: bm.user)}
    numbers = [cubacel_numbers(3), cubacel_numbers(3)]
    lists.each do |l|
      l.stubs(:receivers).returns(numbers.sample)
      bm.lists << l
    end
    counter = Hash.new(0)
    bm.receivers.each {|num| counter[num]+=1 }
    assert counter.values.all? {|v| v == 1 }
  end
end
