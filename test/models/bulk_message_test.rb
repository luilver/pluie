require 'test_helper'

class BulkMessageTest < ActiveSupport::TestCase
  setup do
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
  end

  test "should have message" do
    l = lists(:one)
    bm = BulkMessage.new( user: l.user, route: routes(:one))
    bm.lists << l
    assert bm.invalid?
    bm.message = "hello"
    assert bm.valid?
  end

  test "should have route" do
    l = lists(:one)
    bm = BulkMessage.new(message: "hello", user: l.user)
    bm.lists << l
    assert bm.invalid?
    bm.route = routes(:one)
    assert bm.valid?
  end

  test "should have list" do
    l = lists(:one)
    bm = BulkMessage.new(message: "hello", user: l.user, route: routes(:one))
    assert_not bm.save
    bm.lists << l
    assert bm.valid?
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
