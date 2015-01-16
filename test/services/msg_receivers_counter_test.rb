require 'test_helper'

class MsgReceiversCounterTest < ActiveSupport::TestCase

  setup do
    @numbers = %w(5354031333 5351141112 5352527689 5351262611 5352782076)
  end

  test "should count single_messages receivers" do
    sm = SingleMessage.new
    sm.expects(:valid_gsm_numbers_from_field).returns(@numbers)
    assert_equal @numbers.size, SingleMsgReceiversCounter.count(sm)

    #Simulates saving the record to DB
    sm.stubs(:gsm_numbers).returns(@numbers.map { |n| GsmNumber.new(number: n) })
    assert_equal @numbers.size, SingleMsgReceiversCounter.count(sm)
  end

  test "should count bulk_messages receivers" do
    list = List.new
    list.expects(:receivers).returns(@numbers)
    bulk = BulkMessage.new(lists: [list])
    assert_equal @numbers.size, BulkMsgReceiversCounter.count(bulk)
  end
end
