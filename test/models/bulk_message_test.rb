require 'test_helper'

class BulkMessageTest < ActiveSupport::TestCase
  test "should have message" do
    bm = BulkMessage.random
    assert_not bm.message.blank?
  end
end
