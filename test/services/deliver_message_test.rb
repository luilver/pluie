require 'test_helper'

class DeliverMessageTest < ActiveSupport::TestCase

  setup do
    stub_request_for_async_test
  end

  test "creates DLR and charge to user when sending single message" do
    msg = single_messages(:one)

    assert_difference 'ActionSmser::DeliveryReport.count'  do
      assert_message_is_charged(msg, SingleDeliverer)
    end
  end

  test "create DLRs and charge cost to user" do
    bm = bulk_messages(:bulk)
    numbers = Set.new(cubacel_numbers(120)).to_a
    List.any_instance.stubs(:receivers).returns(numbers).at_least_once

    assert_difference 'ActionSmser::DeliveryReport.count', numbers.size  do
      assert_message_is_charged(bm, BulkDeliverer)
    end
  end
end
