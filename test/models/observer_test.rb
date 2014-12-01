require 'test_helper'

class ObserverTest < ActiveSupport::TestCase
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
end
