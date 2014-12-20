require 'test_helper'

class ListTest < ActiveSupport::TestCase
  should have_attached_file :file
  should validate_attachment_content_type(:file).allowing('text/plain')
  should validate_attachment_presence(:file)
  should validate_presence_of :name

  setup do
    @list = List.new(opened: true)
    @numbers = cubacel_numbers(10)
  end

  teardown do
    clean_paperclip_file_directory
  end

  test "receivers has numbers in opened list" do
    k = @numbers.size
    @list.stubs(:lines_with_cubacel_numbers).returns(@numbers)
    assert_equal 0, @list.gsm_numbers.count
    assert_equal k, @list.receivers.count
  end

  test "repeated numbers not in gsm_number" do
    i = @numbers.size / 4
    j =  i * 2
    @numbers.push( *@numbers[i..j])
    @list.stubs(:lines_with_cubacel_numbers).returns(@numbers)
    set = Set.new(@numbers)
    @list.attach_numbers
    assert_equal set.size, @list.gsm_numbers.count
  end

  test "attach and remove numbers using several files" do
    k = @numbers.size
    @list.stubs(:lines_with_cubacel_numbers).returns(@numbers)
    @list.attach_numbers
    assert_equal k, @list.gsm_numbers.count

    new_numbers = cubacel_numbers(5)
    @list.stubs(:lines_with_cubacel_numbers).returns(new_numbers)
    @list.attach_numbers
    k += new_numbers.size

    assert_equal k, @list.gsm_numbers.count

    id = @list.id
    assert_difference 'List.find(id).gsm_numbers.count', -new_numbers.size do
      @list.remove_numbers
    end
  end

  test "should ignore invalid numbers from list" do
    nums = @numbers + %w(3123 515212212 53555552 212125342) + cubacel_numbers(4)
    nums.shuffle!
    @list.stubs(:lines_from_file).returns(nums)
    @list.update_attribute(:opened, true)
    m = /535[0-9]{7}/
    @list.receivers.each do |num|
      assert_match m, num
    end
    @list.update_attribute(:opened, false)
    @list.receivers.each do |num|
      assert_match m, num
    end
    @list.gsm_numbers.each do |gsm|
      assert_match m, gsm.number
    end
  end
end
