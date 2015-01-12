require 'test_helper'

class BulkMessageTest < ActiveSupport::TestCase
  should validate_presence_of :lists
  should validate_presence_of :route
  should validate_presence_of :message

  context "BulkMessage" do
    setup do
      @numbers = %w(5354033333 5351111112 5352523689)
    end

    should "verify that user has balance to paid" do
      user = User.new
      user.expects(:balance).returns(1)
      expensive_route = Route.new
      expensive_route.expects(:price).returns(10).at_least_once
      list = List.new
      list.expects(:receivers).returns(@numbers).at_least_once
      bm = BulkMessage.new(user: user, route: expensive_route, message: "some message", lists: [list])
      assert bm.invalid?
      error_msg = I18n.t('errors.messages.insufficient_funds', cost: @numbers.size * 10).html_safe
      assert_includes  bm.errors.full_messages, error_msg

      user.expects(:balance).returns(100)
      assert bm.valid?
    end

    should "calculate message_cost" do
      bm = BulkMessage.new(message: "hello there")
      bm.expects(:receivers).returns(@numbers)
      bm.expects(:route).returns(stub(:price => 2))
      assert_equal ActionSmserUtils.sms_cost(@numbers.size, 2, 1), bm.message_cost
    end

    should "not repeat numbers from lists" do
      bm = BulkMessage.new
      bm.lists = generate_collection(4) {List.new}
      numbers = [@numbers, cubacel_numbers(3)]
      filtered = Set.new
      bm.lists.each do |l|
        nums = numbers.sample
        l.expects(:receivers).returns(nums)
        filtered.merge(nums)
      end
      assert_same_elements(bm.receivers, filtered)
    end
  end
end
