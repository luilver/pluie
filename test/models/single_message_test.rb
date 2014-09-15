require 'test_helper'

class SingleMessageTest < ActiveSupport::TestCase
  test "should have message" do
    sm = SingleMessage.random
    assert_not sm.message.blank?
  end

  test "should have number" do
    sm = SingleMessage.random
    assert_not sm.number.blank?
  end
end
