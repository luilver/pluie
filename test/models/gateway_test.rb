require 'test_helper'

class GatewayTest < ActiveSupport::TestCase
  test "should have price" do
    gateway = Gateway.random
    assert_not gateway.price.blank?
  end

  test "should have name" do
    gateway = Gateway.random
    assert_not gateway.name.blank?
  end
end
