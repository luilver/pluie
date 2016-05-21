require 'test_helper'

class TableRoutesControllerTest < ActionController::TestCase
  setup do
    @table_route = table_routes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:table_routes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create table_route" do
    assert_difference('TableRoute.count') do
      post :create, table_route: { country: @table_route.country, country_code: @table_route.country_code, name_route: @table_route.name_route, price_cost: @table_route.price_cost, price_system: @table_route.price_system }
    end

    assert_redirected_to table_route_path(assigns(:table_route))
  end

  test "should show table_route" do
    get :show, id: @table_route
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @table_route
    assert_response :success
  end

  test "should update table_route" do
    patch :update, id: @table_route, table_route: { country: @table_route.country, country_code: @table_route.country_code, name_route: @table_route.name_route, price_cost: @table_route.price_cost, price_system: @table_route.price_system }
    assert_redirected_to table_route_path(assigns(:table_route))
  end

  test "should destroy table_route" do
    assert_difference('TableRoute.count', -1) do
      delete :destroy, id: @table_route
    end

    assert_redirected_to table_routes_path
  end
end
