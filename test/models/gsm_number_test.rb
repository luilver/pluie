require 'test_helper'

class GsmNumberTest < ActiveSupport::TestCase
  should allow_value("5351232265").for(:number)
  should_not allow_value("54021461").for(:number)
end
