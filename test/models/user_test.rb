require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @rnd = Random.new
  end

  test "should have email" do
    user = User.choose_random
    assert_not user.email.blank?
  end

  test "credits sum should equals user credit" do
    user = users(:without_credits)
    10.times{ |i| Credit.create(balance: @rnd.rand(1..10), user: user, description: "test") }
    assert_equal user.credits.to_a.sum {|c| c.balance}, user.credit
  end

  test "debits sum should equals user debit" do
    user = users(:without_credits)
    10.times{ |i| Debit.create(balance: @rnd.rand(1..10), user: user) }
    assert_equal user.debits.to_a.sum {|c| c.balance}, user.debit
  end

  test "billing creates debit" do
    user = users(:one)
    assert_difference ['Debit.count', 'User.find(user.id).debits.count'] do
      user.bill_sms(1)
    end
  end
end
