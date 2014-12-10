require 'test_helper'

class ObserverTest < ActiveSupport::TestCase

  setup do
    Observer.all.each do |single|
      single.save
    end
  end

  test "should have number" do
    ob = Observer.new()
    assert_not ob.save
    ob.number =  cubacel_random_number
    assert ob.save
  end

  test "should be a cubacel number" do
    ob = Observer.new(number: "2123234131")
    assert ob.invalid?
    assert_includes ob.errors[:number], I18n.t('errors.messages.valid_gsm_number_format').html_safe
    ob.number = cubacel_random_number
    assert ob.save
  end

  test "should obtain active observers" do
    Observer.create(number: cubacel_random_number, active: true)
    Observer.create(number: cubacel_random_number, active: false)
    active_observers = Observer.active.to_a

    Observer.where(active: true) do |obs|
      assert_includes active_observers, obs
    end
    Observer.where(active: false) do |obs|
      assert_not_includes active_observers, obs
    end
  end

  test "should notify active observers after sending" do
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
    sm = single_messages(:one)
    assert_observers_are_notified(sm, SingleDeliverer)

    bm = bulk_messages(:bulk)
    list = lists(:two)
    list.stubs(:receivers).returns(cubacel_numbers(50))
    bm.lists << list
    assert_observers_are_notified(bm, BulkDeliverer)
  end

  def assert_observers_are_notified(msg, deliverer)
    user_id = Route.notifications_route.user.id
    observers_count = Observer.active.to_a.size
    cost = ActionSmserUtils.sms_cost(observers_count, Route.notifications_route.price, 1)
    data = [['User.find(user_id).delivery_reports.count', observers_count],
            ['User.find(user_id).bills.count', 1],
            ['User.find(user_id).balance', -cost]]
    assert_differences data do
      MessageProcessor.deliver(msg, deliverer, DeliveryNotifier)
    end
  end
end
