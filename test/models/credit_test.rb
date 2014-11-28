require 'test_helper'

class CreditTest < ActiveSupport::TestCase

  setup do
    fix_users_credit
    @user = users(:two)
    @rnd = Random.new
  end
  test "should have user" do
    credit = Credit.choose_random
    assert_not credit.user.blank?
  end

  test "should have balance" do
    credit = Credit.choose_random
    assert_not credit.balance.blank?
  end

  test "new credits increase user credit" do
    @user = users(:two)
    initial_credit =  @user.credit
    amounts = []
    5.times do
      amounts << @rnd.rand(1..15)
      Credit.create(balance: amounts.last, user: @user, description: "testing")
    end
    assert_equal @user.credit, initial_credit + amounts.sum
  end

  test "balance should be positive" do
    credit = Credit.new(balance: -1, user: @user, description: "testing")
    assert credit.invalid?
    credit.balance = 1
    assert credit.valid?
  end

  test "should update user balance when credit is updated" do
    init_value = @rnd.rand(10..300)
    final_value  = @rnd.rand(1..init_value)
    diff = init_value - final_value
    c = Credit.create(balance: init_value, user: @user, description: "add #{init_value} coins")
    user_balance = @user.balance
    id = @user.id
    assert_difference 'User.find(id).balance', -diff do
      c.update(balance: final_value, description: "remove #{diff} coins from the initial #{init_value}")
    end
  end
end
