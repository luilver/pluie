require 'test_helper'

class ListTest < ActiveSupport::TestCase
  should have_attached_file :file
  should validate_attachment_content_type(:file).allowing('text/plain')
  should validate_attachment_presence(:file)
  should validate_presence_of :name

  context "A new List" do
    setup do
      @numbers = %w(5354033333 5351111112 5352523689 5351242611 5352789076)
      @list = List.new
    end

    should "have receivers and avoid repeated numbers" do
      k = @numbers.size
      @list.stubs(:lines_with_cubacel_numbers).returns(@numbers)
      assert_equal 0, @list.gsm_numbers.count
      assert_equal k, @list.receivers.count

      new_numbers = @numbers + @numbers.sample(k / 2)
      @list.stubs(:lines_with_cubacel_numbers).returns(new_numbers)
      @list.attach_numbers
      assert_equal k, @list.gsm_numbers.count
    end

    should "attach and remove numbers" do
      k = @numbers.size
      @list.stubs(:lines_with_cubacel_numbers).returns(@numbers)
      @list.attach_numbers

      id = @list.id
      new_numbers =  [@numbers.first] +  %w(5358222689 5351942211 5352789573) #A repeated number
      assert_difference 'List.find(id).gsm_numbers.count', 3 do
        @list.stubs(:lines_with_cubacel_numbers).returns(new_numbers)
        @list.attach_numbers
      end

      assert_difference 'List.find(id).gsm_numbers.count', -new_numbers.size do
        @list.remove_numbers
      end
    end

    should "ignore invalid numbers from file" do
      nums = @numbers + %w(3123 515212212 53555552 212125342)
      nums.shuffle!
      @list.stubs(:lines_from_file).returns(nums)
      m = /535[0-9]{7}/
      @list.receivers.each do |num|
        assert_match m, num
      end
      @list.attach_numbers
      @list.receivers.each do |num|
        assert_match m, num
      end
      @list.gsm_numbers.each do |gsm|
        assert_match m, gsm.number
      end
    end
  end
end
