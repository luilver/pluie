require 'test_helper'

class CreditTest < ActiveSupport::TestCase
  test "should have user" do
    credit = Credit.random
    assert_not credit.user.blank?
  end

  test "should have balance" do
    credit = Credit.random
    assert_not credit.balance.blank?
  end
end
