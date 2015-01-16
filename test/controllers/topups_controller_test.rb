require 'test_helper'

class TopupsControllerTest < ActionController::TestCase
  setup do
    @topup = topups(:one)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = users(:two)
    sign_in @user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:topups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create topup" do
    ticket = stub_soap_response(:get_session_ticket)
    recharge_response = stub_soap_response(:recharge_phone)
    Savon::Client.any_instance.stubs(:build_request).returns(stub(body: ""))
    Savon::Client.any_instance.stubs(:call).with(:get_session_ticket, {xml: ""}).returns(ticket)
    Savon::Client.any_instance.stubs(:call).with(:recharge_phone, {xml: ""}).returns(recharge_response)

    assert_difference 'Topup.count' do
      post :create, topup: { number: @topup.number, amount: @topup.amount }
    end
    assert_redirected_to topup_path(assigns(:topup))
  end

  test "should show topup" do
    get :show, id: @topup
    assert_response :success
  end

  test "user can not update or destroy topup" do
    get :edit, id: @topup
    assert_response :redirect

    patch :update, id: @topup, topup: { number: "5353232222", amount: 30 }
    assert_response :redirect

    assert_difference('Topup.count', 0) do
      delete :destroy, id: @topup
    end
    assert_response :redirect
  end

  test "admin can update and destroy topup" do
    admin = users(:admin)
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in admin

    get :edit, id: @topup
    assert_response :success

    patch :update, id: @topup, topup: { number: "5353232222", amount: 30 }
    assert_redirected_to topup_path(assigns(:topup))

    assert_difference('Topup.count', -1) do
      delete :destroy, id: @topup
    end
    assert_redirected_to topups_path
  end
end
