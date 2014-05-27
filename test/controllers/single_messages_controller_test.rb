require 'test_helper'

class SingleMessagesControllerTest < ActionController::TestCase
  setup do
    @single_message = single_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:single_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create single_message" do
    assert_difference('SingleMessage.count') do
      post :create, single_message: { message: @single_message.message, number: @single_message.number }
    end

    assert_redirected_to single_message_path(assigns(:single_message))
  end

  test "should show single_message" do
    get :show, id: @single_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @single_message
    assert_response :success
  end

  test "should update single_message" do
    patch :update, id: @single_message, single_message: { message: @single_message.message, number: @single_message.number }
    assert_redirected_to single_message_path(assigns(:single_message))
  end

  test "should destroy single_message" do
    assert_difference('SingleMessage.count', -1) do
      delete :destroy, id: @single_message
    end

    assert_redirected_to single_messages_path
  end
end
