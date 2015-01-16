require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  should validate_presence_of :user
  should validate_presence_of :balance
  should validate_numericality_of(:balance).is_greater_than(0)

  context "Credit" do
    setup do
      @user = users(:two)
    end

    should "increase user balance when credit is created" do
      amounts = (20..220).step(40)
      sum = amounts.sum
      id = @user.id

      assert_difference 'User.find(id).balance', sum do
        amounts.each do |c|
          Credit.create(balance: c, user: @user, description: "balance #{c}")
        end
      end
    end

    should "update user balance when credit is updated" do
      init_value = random.rand(10..300)
      final_value  = random.rand(1..init_value)
      diff = init_value - final_value
      c = Credit.create(balance: init_value, user: @user, description: "add #{init_value} coins")
      id = @user.id
      assert_difference 'User.find(id).balance', -diff do
        c.update(balance: final_value, description: "remove #{diff} coins from the initial #{init_value}")
      end
    end
  end
end
