require 'test_helper'

class CreditTest < ActiveSupport::TestCase

  setup do
    fix_users_credit
    @user = users(:two)
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
    r = Random.new
    amounts = []
    5.times do
      amounts << r.rand(1..15)
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
end
