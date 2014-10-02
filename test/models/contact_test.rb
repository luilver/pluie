require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  test "should have name" do
    contact = Contact.random
    assert_not contact.name.blank?
  end
end
