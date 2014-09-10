require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  test "should have gateway" do
    r = Route.random
    assert_not r.gateway.blank?
  end

  test "should have user" do
    r = Route.random
    assert_not r.user.blank?
  end

  test "should have price" do
    r = Route.random
    assert_not r.price.blank?
  end

  test "should have name" do
    r = Route.random
    assert_not r.name.blank?
  end
end
