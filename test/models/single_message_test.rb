require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase
  should validate_presence_of :route
  should validate_presence_of :message
  should validate_presence_of :number

  context "New SingleMessage" do
    setup do
      @numbers = %w(5354033333 5351111112 5352523689 5351242611 5352789076)
    end

    should "create gsm_numbers and receivers" do
      user = User.new
      user.stubs(:balance => 5)
      route = Route.new(price: 1)
      sm = SingleMessage.new(user: user, message: "hi folks", route: route, number: @numbers.join(" "))
      assert_difference 'sm.gsm_numbers.count', 5 do
        sm.save
      end
      assert_same_elements(@numbers, sm.receivers)
    end

    should "use only valid gsm from number field" do
      input = "53423 3 323 #{@numbers.join(" ")} 2021887  53543321 535"
      sm = SingleMessage.new(number: input)
      assert_same_elements(@numbers, sm.valid_gsm_numbers_from_field)
    end
  end

  context "SingleMessage" do
    setup do
      @msg = single_messages(:with_three_numbers)
    end

    should "have the same gsm_numbers and receivers" do
      assert_same_elements(@msg.gsm_numbers.pluck(:number), @msg.receivers)
    end

    should "estimate message cost" do
      assert_equal @msg.route.price * 3 , @msg.message_cost
    end
  end
end
