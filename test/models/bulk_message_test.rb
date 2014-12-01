require 'test_helper'

class BulkMessageTest < ActiveSupport::TestCase
  setup do
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
    fix_users_credit
  end

  teardown do
    clean_paperclip_file_directory
  end

  test "should have message" do
    l = setup_list(:one)
    bm = BulkMessage.new( user: l.user, route: routes(:one))
    bm.lists << l
    assert bm.invalid?
    bm.message = "hello"
    assert bm.valid?
  end

  test "should have route" do
    l = setup_list(:one)
    bm = BulkMessage.new(message: "hello", user: l.user)
    bm.lists << l
    assert bm.invalid?
    bm.route = routes(:one)
    assert bm.valid?
  end

  test "should have list" do
    l = setup_list(:one)
    bm = BulkMessage.new(message: "hello", user: l.user, route: routes(:one))
    assert_not bm.save
    bm.lists << l
    assert bm.valid?
  end

  test "creates msg only if user has balance to paid" do
    r = routes(:expensive)
    list = lists(:one)
    attach_file_from_fixture(list, "10000.txt")
    bm = bulk_messages(:one)
    bm.route = r
    bm.lists << list
    assert bm.invalid?

    bm2 = bulk_messages(:bulk)
    list.update(user: bm2.user)
    bm2.lists << list
    assert bm2.valid?
  end

  test "should create DLRs" do
    list = setup_list(:two)
    bm = bulk_messages(:bulk)
    bm.lists << list
    num_count = bm.gsm_numbers_count

    assert_difference 'ActionSmser::DeliveryReport.count', num_count do
      bm.deliver
    end
  end

  test "should charge msg cost to user" do
    bm = bulk_messages(:bulk)
    list = setup_list(:l_500)
    bm.lists << list
    assert_msg_is_charged(bm)
  end

  test "should send from multiple lists" do
    bm = bulk_messages(:multi_lists)
    bm.lists.each {|l| attach_file_from_fixture(l)}
    assert_msg_is_charged(bm)
  end

  test "should not repeat numbers from lists" do
    bm = bulk_messages(:multi_lists)
    bm.lists << lists(:dup_two)
    counter = Hash.new(0)
    bm.lists.each {|l| attach_file_from_fixture(l); l.attach_numbers;}
    bm.receivers.each {|num| counter[num]+=1 }
    assert counter.values.all? {|v| v == 1 }
  end

  def assert_msg_is_charged(bm)
    cost = bm.message_cost
    id = bm.user.id
    assert_difference 'User.find(id).balance', -cost do
      bm.deliver
    end
  end
end
