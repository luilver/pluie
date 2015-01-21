require 'test_helper'

class CreateMessagesTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  Warden.test_mode!

  test "send bulk using list without gsm numbers" do
    user = users(:two)
    login_as(user, scope: :user)
    route = user.routes.first
    list = lists(:no_gsm_numbers)
    assert list.update(file: File.new(file_path_from_fixtures("1000.txt")))

    get new_bulk_message_path
    stub_request_for_async_test
    data = [
      ["deliveries_test_array.size", 11], #Observers sms + 10 sms resulting from taking a 0.1 slice or receivers to each sms
      ["User.find(user.id).delivery_reports.where(status: ActionSmserUtils::SENT_STATUS).count", 1000]
    ]
    assert_differences data do
      post_via_redirect bulk_messages_path, {bulk_message: {message: "a message", route_id: route.id}, list_ids: [list.id]}
    end
  end

  test "should not create message when balance is lower than cost" do
    user = users(:without_credits)
    login_as(user, scope: :user)
    route = user.routes.first

    get new_single_message_path
    assert_response :success

    assert_no_difference 'SingleMessage.count' do
      post_via_redirect  single_messages_path, single_message: {number: cubacel_random_number, message: "some message", route_id: route.id}
    end

    sm = assigns(:single_message)
    estimated_cost = sm.message_cost
    assert_includes sm.errors.full_messages, I18n.t('errors.messages.insufficient_funds', cost: estimated_cost).html_safe
    assert_template :new

    get new_bulk_message_path
    assert_response :success

    List.any_instance.stubs(:receivers).returns(cubacel_numbers(10))
    assert_no_difference 'BulkMessage.count' do
      post_via_redirect bulk_messages_path, {bulk_message: {message: "a message", route_id: route.id}, list_ids: user.lists.pluck(:id)}
    end

    bm = assigns(:bulk_message)
    estimated_cost = bm.message_cost
    assert_includes bm.errors.full_messages, I18n.t('errors.messages.insufficient_funds', cost: estimated_cost).html_safe
    assert_template :new
  end
end
