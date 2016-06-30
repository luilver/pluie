require 'test_helper'

class HistoricLogsControllerTest < ActionController::TestCase
  setup do
    @historic_log = historic_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:historic_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create historic_log" do
    assert_difference('HistoricLog.count') do
      post :create, historic_log: { action_name: @historic_log.action_name, controller_name: @historic_log.controller_name, user_id: @historic_log.user_id }
    end

    assert_redirected_to historic_log_path(assigns(:historic_log))
  end

  test "should show historic_log" do
    get :show, id: @historic_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @historic_log
    assert_response :success
  end

  test "should update historic_log" do
    patch :update, id: @historic_log, historic_log: { action_name: @historic_log.action_name, controller_name: @historic_log.controller_name, user_id: @historic_log.user_id }
    assert_redirected_to historic_log_path(assigns(:historic_log))
  end

  test "should destroy historic_log" do
    assert_difference('HistoricLog.count', -1) do
      delete :destroy, id: @historic_log
    end

    assert_redirected_to historic_logs_path
  end
end
