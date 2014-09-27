require 'test_helper'

class ObserversControllerTest < ActionController::TestCase
  setup do
    @observer = observers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:observers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create observer" do
    assert_difference('Observer.count') do
      post :create, observer: { active: @observer.active, number: @observer.number }
    end

    assert_redirected_to observer_path(assigns(:observer))
  end

  test "should show observer" do
    get :show, id: @observer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @observer
    assert_response :success
  end

  test "should update observer" do
    patch :update, id: @observer, observer: { active: @observer.active, number: @observer.number }
    assert_redirected_to observer_path(assigns(:observer))
  end

  test "should destroy observer" do
    assert_difference('Observer.count', -1) do
      delete :destroy, id: @observer
    end

    assert_redirected_to observers_path
  end
end
