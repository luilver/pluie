require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "should have name" do
    contact = Contact.choose_random
    assert_not contact.name.blank?
  end
end
