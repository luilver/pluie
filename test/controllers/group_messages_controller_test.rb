require 'test_helper'

class GroupMessagesControllerTest < ActionController::TestCase
  setup do
    @group_message = group_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:group_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group_message" do
    assert_difference('GroupMessage.count') do
      post :create, group_message: { group_id: @group_message.group_id, message: @group_message.message }
    end

    assert_redirected_to group_message_path(assigns(:group_message))
  end

  test "should show group_message" do
    get :show, id: @group_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group_message
    assert_response :success
  end

  test "should update group_message" do
    patch :update, id: @group_message, group_message: { group_id: @group_message.group_id, message: @group_message.message }
    assert_redirected_to group_message_path(assigns(:group_message))
  end

  test "should destroy group_message" do
    assert_difference('GroupMessage.count', -1) do
      delete :destroy, id: @group_message
    end

    assert_redirected_to group_messages_path
  end
end
