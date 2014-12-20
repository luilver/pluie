require 'test_helper'

class RouteTest < ActiveSupport::TestCase
  should validate_presence_of :gateway
  should validate_presence_of :user
  should validate_presence_of :price
  should validate_presence_of :name
  should validate_numericality_of(:price).is_greater_than(0)

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
