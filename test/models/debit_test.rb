require 'test_helper'

class DebitTest < ActiveSupport::TestCase
  should validate_presence_of :user
  should validate_presence_of :balance
  should validate_numericality_of(:balance).is_greater_than(0)

  setup do
    @user = users(:one)
  end

  test "new debits increase user debit" do
    rnd = Random.new
    debits = []
    5.times{|i| debits << Debit.create(balance: rnd.rand(0.1.. 5), user: @user)}
    assert_equal @user.debit, debits.sum {|d| d.balance}
  end
end
