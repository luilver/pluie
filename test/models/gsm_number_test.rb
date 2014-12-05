require 'test_helper'

class GsmNumberTest < ActiveSupport::TestCase

  test "number should have a cubacel format" do
    gsm = GsmNumber.new(number: "53412211")
    assert gsm.invalid?
    assert_includes gsm.errors[:number], I18n.t('errors.messages.valid_gsm_number_format').html_safe
    gsm.number = cubacel_random_number
    assert gsm.valid?
  end
end
