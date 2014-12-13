require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :email

  setup do
    @rnd = Random.new
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
    #TODO use fractional quantities
    user = users(:one)
    id = user.id
    n = 5
    amounts = []
    n.times {amounts << @rnd.rand(1..10)}
    total = amounts.sum
    expressions = [['Debit.count', n], ['User.find(id).debits.count', n], ['User.find(id).debit', total]]
    assert_differences expressions do
      amounts.each {|a| user.bill_sms(a)}
    end
  end

  test "balance equals credits minus debits" do
    u = users(:without_credits)
    n = 20
    n.times do |i|
      v = @rnd.rand(0.0..i.succ)
      if @rnd.rand < 0.5
        Credit.create!(balance: v, description: "test credit: #{v}", user: u)
      else
        Debit.create!(balance: v, user: u)
      end
    end
    assert_equal u.balance, (u.credit - u.debit)
  end
end
