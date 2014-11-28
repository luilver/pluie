require 'test_helper'

class DebitTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end
  test "should take positive balance only" do
    dbt = Debit.new(balance: -1, user: @user)
    assert dbt.invalid?
    dbt.balance = 4
    assert dbt.valid?
    assert Debit.new(user: @user).invalid?
  end

  test "should have user related" do
    d = Debit.new(balance: 3)
    assert d.invalid?
  end

  test "new debits increase user debit" do
    rnd = Random.new
    debits = []
    5.times{|i| debits << Debit.create(balance: rnd.rand(0.1.. 5), user: @user)}
    assert_equal @user.debit, debits.sum {|d| d.balance}
  end
end
