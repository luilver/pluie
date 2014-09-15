require 'test_helper'

class SmsTest < ActiveSupport::TestCase
  test "should have msg type" do
    sms = Sms.random
    assert_not sms.msg_type.blank?
  end
end
