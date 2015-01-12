require 'test_helper'

class ObserverTest < ActiveSupport::TestCase
  should validate_presence_of :number
  should allow_value("5354231267").for(:number)

  #TODO... decrease DB access HERE

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

  test "should update observers" do
    observer_numbers = Observer.active.map { |e| e.gsm_number.number  }
    stub_request(:any, gateway_url_for_tests).to_return { |request| {:body =>  simple_response(request) } }
    sm = single_messages(:one)
    assert_delivery_notified_to_observers(sm, SingleDeliverer)
    Observer.all.each do |obs|
      status = obs.active
      obs.update_attribute(:active, !status)
    end
    assert_delivery_notified_to_observers(sm, SingleDeliverer)
  end

  test "should notify active observers after sending" do
    stub_request_for_async_test
    sm = single_messages(:one)
    assert_delivery_notified_to_observers(sm, SingleDeliverer)

    bm = bulk_messages(:bulk)
    list = lists(:two)
    list.stubs(:receivers).returns(cubacel_numbers(50))
    bm.lists << list
    assert_delivery_notified_to_observers(bm, BulkDeliverer)
  end

  test "should notify status update" do
    stub_request_for_async_test
    observer = Observer.new(number: cubacel_random_number)
    observer.subscribe(ObserverStatusListener.default_instance)
    assert_difference 'deliveries_test_array.size' do
      observer.save
      assert deliveries_test_array.last.body.include?("añadido")
    end
    assert_difference 'deliveries_test_array.size', 2 do
      observer.update_attribute(:active, true)
      assert deliveries_test_array.last.body.include?("activado")
      observer.update(active: false)
      assert deliveries_test_array.last.body.include?("desactivado")
    end
    assert_difference 'deliveries_test_array.size' do
      observer.destroy
      assert deliveries_test_array.last.body.include?("eliminado")
    end
  end

  def assert_delivery_notified_to_observers(msg, deliverer)
    deliveries_test_array.clear
    user_id = Route.notifications_route.user.id
    observers_nums = Observer.active_numbers
    observers_count = observers_nums.count
    cost = ActionSmserUtils.sms_cost(observers_count, Route.notifications_route.price, 1)
    data = [
            ['User.find(user_id).delivery_reports.count', observers_count],
            ['User.find(user_id).bills.count', 1],
            ['User.find(user_id).balance', -cost]]
    assert_differences data do
      cmd = DeliverMessage.new(deliverer, DeliveryNotifier)
      cmd.deliver(msg)
    end
  end
end
