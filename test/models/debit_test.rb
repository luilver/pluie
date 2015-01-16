require 'test_helper'

class DebitTest < ActiveSupport::TestCase
  should validate_presence_of :user
  should validate_presence_of :balance
  should validate_numericality_of(:balance).is_greater_than(0)

  context "Debit" do
    setup do
      @user = users(:one)
    end

    #Prefer this test over the similar one in user,
    #because this checks for user balance
    #instead of the more specific concepts, credit & debit
    should "decrease user balance" do
      amounts = generate_collection(10) { BigDecimal.new(random.rand( 8..50000), 4)/1000}
      total = amounts.sum

      assert_difference 'User.find(@user.id).balance', -total do
        amounts.each do |dbt|
          Debit.create(balance: dbt, user: @user)
        end
      end
    end
  end
end
