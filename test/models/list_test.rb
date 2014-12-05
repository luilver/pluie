require 'test_helper'

class ListTest < ActiveSupport::TestCase
  should have_attached_file :file
  should validate_attachment_content_type(:file).allowing('text/plain')
  should validate_attachment_presence(:file)

  teardown do
    clean_paperclip_file_directory
  end

  test "receiver match list count" do
    list_1k = lists(:l_1k)
    attach_file_from_fixture(list_1k, "1000.txt")
    assert_equal list_1k.gsm_numbers.count, 0
    assert_equal list_1k.receivers.count, 1000
  end

  test "repeated numbers not in gsm_number" do
    @l2 = setup_list(:dup, false)
    set = Set.new(@l2.receivers)
    @l2.attach_numbers
    assert_equal set.size, @l2.gsm_numbers.count
  end

  test "attach and remove numbers using several files" do
    @l1 = setup_list(:one)
    assert_equal @l1.gsm_numbers.count, 3

    attach_file_from_fixture(@l1, "six_numbers.txt")
    @l1.attach_numbers

    assert_equal @l1.gsm_numbers.count, 9

    assert_difference '@l1.gsm_numbers.count', -3 do
      attach_file_from_fixture(@l1, "random3.txt")
      @l1.remove_numbers
    end
  end

  test "should ignore invalid numbers from list" do
    l1 = setup_list(:wrong_nums_in_list)
    l1.update_attribute(:opened, true)
    m = /535[0-9]{7}/
    l1.receivers.each do |num|
      assert_match m, num
    end
    l1.update_attribute(:opened, false)
    l1.receivers.each do |num|
      assert_match m, num
    end
    l1.gsm_numbers.each do |gsm|
      assert_match m, gsm.number
    end
  end
end
