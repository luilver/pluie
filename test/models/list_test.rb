require 'test_helper'

class ListTest < ActiveSupport::TestCase
  should have_attached_file :file
  should validate_attachment_content_type(:file).allowing('text/plain')
  should validate_attachment_presence(:file)

  setup do
    @list_1k = lists(:list_1k_for_one)
  end

  teardown do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/test_files/"])
  end

  test "receiver match list count" do
    @list_1k.file = file_from_fixtures_dir("1000.txt")
    @list_1k.save
    assert_equal @list_1k.gsm_numbers.count, 0
    assert_equal @list_1k.receivers.count, 1000
  end

  test "repeated numbers not in gsm_number" do
    @l2 = lists(:two)
    @l2.file = file_from_fixtures_dir("some-duplicates.txt")
    @l2.save

    set = Set.new(@l2.receivers)
    @l2.attach_numbers
    assert_equal set.size, @l2.gsm_numbers.count
  end

  test "attach and remove numbers using several files" do
    @l1 = lists(:one)
    @l1.file = file_from_fixtures_dir("random3.txt")
    @l1.save
    @l1.attach_numbers
    assert_equal @l1.gsm_numbers.count, 3

    @l1.file = file_from_fixtures_dir("six_numbers.txt")
    @l1.save
    @l1.attach_numbers

    assert_equal @l1.gsm_numbers.count, 9

    assert_difference '@l1.gsm_numbers.count', -3 do
      @l1.file = file_from_fixtures_dir("random3.txt")
      @l1.save
      @l1.remove_numbers
    end
  end

end
