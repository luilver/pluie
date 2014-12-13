require 'test_helper'

class GatewayTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_uniqueness_of(:name).case_insensitive
  should validate_numericality_of(:price).is_greater_than(0)
end
