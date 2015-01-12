require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :email

  context "User" do
    setup do
      @amounts = [1000, 8, 234, 11000, 22500, 4200, 27500, 1500 ].map { |e| BigDecimal.new(e, 4)/1000}
    end

    should "have credit equals to sum of all credits" do
      user = users(:without_credits)
      @amounts.each do |amount|
        Credit.create(balance: amount, user: user, description: "test")
      end
      assert_equal user.credits.pluck(:balance).sum, user.credit
    end

    should "have credit equals to sum of all debits" do
      user = users(:without_credits)
      @amounts.each do |amount|
        Debit.create(balance: amount, user: user)
      end
      assert_equal user.debits.pluck(:balance).sum , user.debit
    end

    should "have debits after billing" do
      user = users(:one)
      id = user.id
      total = @amounts.sum
      n = @amounts.size
      expressions = [['Debit.count', n], ['User.find(id).debits.count', n], ['User.find(id).balance', -total]]
      assert_differences expressions do
        @amounts.each {|a| user.bill_sms(a)}
      end
    end

    should "have balance equals credits minus debits" do
      u = users(:without_credits)
      n = 20
      @amounts.each do |amount|
        if random.rand < 0.5
          Credit.create!(balance: amount, description: "test credit: #{amount}", user: u)
        else
          Debit.create!(balance: amount, user: u)
        end
      end
      assert_equal u.balance, (u.credit - u.debit)
    end
  end
end
