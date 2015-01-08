require 'test_helper'

class CreateMessagesTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers
  Warden.test_mode!

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
