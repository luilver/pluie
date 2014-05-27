require 'test_helper'

class BulkMessagesControllerTest < ActionController::TestCase
  setup do
    @bulk_message = bulk_messages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bulk_messages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bulk_message" do
    assert_difference('BulkMessage.count') do
      post :create, bulk_message: { list_id: @bulk_message.list_id, message: @bulk_message.message }
    end

    assert_redirected_to bulk_message_path(assigns(:bulk_message))
  end

  test "should show bulk_message" do
    get :show, id: @bulk_message
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bulk_message
    assert_response :success
  end

  test "should update bulk_message" do
    patch :update, id: @bulk_message, bulk_message: { list_id: @bulk_message.list_id, message: @bulk_message.message }
    assert_redirected_to bulk_message_path(assigns(:bulk_message))
  end

  test "should destroy bulk_message" do
    assert_difference('BulkMessage.count', -1) do
      delete :destroy, id: @bulk_message
    end

    assert_redirected_to bulk_messages_path
  end
end
