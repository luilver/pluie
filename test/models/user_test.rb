require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should have email" do
    user = User.random
    assert_not user.email.blank?
  end
end
