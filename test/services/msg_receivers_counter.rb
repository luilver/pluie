require 'test_helper'

class MsgReceiversCounter < ActiveSupport::TestCase

  test "should count single_messages receivers" do
    @route = routes(:one)
    msg = SingleMessage.new(number: cubacel_numbers(5).join(" "), user: @route.user, route: @route)
    assert_equal 5, SingleMsgReceiversCounter.count(msg)
    msg.save
    assert_equal 5, SingleMsgReceiversCounter.count(msg)
  end

  test "should count bulk_messages receivers" do
    bulk = bulk_messages(:one)
    bulk.expects(:receivers).returns(cubacel_numbers(20))
    assert_equal 20, BulkMsgReceiversCounter.count(bulk)
  end
end
