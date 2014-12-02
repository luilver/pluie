require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  test "should have gateway" do
    r = routes(:barebones)
    r.user = users(:one)
    assert r.invalid?
    r.gateway = gateways(:one)
    assert r.valid?
  end

  test "should have user" do
    r = routes(:barebones)
    r.gateway = gateways(:one)
    assert_not r.valid?
    r.user = users(:one)
    assert r.valid?
  end

  test "should have price" do
    r = Route.choose_random
    assert_not r.price.blank?
  end

  test "should have name" do
    r = Route.choose_random
    assert_not r.name.blank?
  end

  test "should use gateway name to create symbols" do
    r = routes(:one)
    r.gateway.stub(:name, "gateway") do
      assert_equal r.gateway_to_sym, :gateway
      assert_equal r.dlv_to_sym, :async_gateway
    end
  end

  test "should obtain system routes" do
    Route.create(gateway: gateways(:one))
    pubs =  Route.publisher_routes
    actives = Route.where(system_route: true)
    pubs.each do |r|
      assert_includes actives, r
    end
  end
end
