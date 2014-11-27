require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should have email" do
    user = User.choose_random
    assert_not user.email.blank?
  end
end
