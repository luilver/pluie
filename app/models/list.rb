class List < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :gsm_numbers
  has_and_belongs_to_many :bulk_messages
  has_attached_file :file

  validates :name, presence: true
  validates_presence_of :file, :message => I18n.translate(:paperclip_file_presence)
  validates_attachment :file, content_type: { content_type: ["text/plain"]}

  def attach_numbers
    if self.file.path
      self.update_attribute(:opened, true)
      numbers = valid_cubacel_numbers_from_file.map{ |line| GsmNumber.find_or_create_by(number: line[0,10]) }
      from_file = Set.new(numbers)
      new_numbers = from_file - self.gsm_numbers.to_a
      self.gsm_numbers << new_numbers.to_a
      self.update_attribute(:opened, false)
    end
  end

  def remove_numbers
    if self.file.path
      self.update_attribute(:opened, true)
      numbers = IO.foreach(self.file.path).map{ |line| GsmNumber.find_by_number(line[0,10]) }
      from_file = Set.new(numbers)
      erase_this = from_file & self.gsm_numbers.to_a
      self.gsm_numbers.delete(erase_this.to_a)
      self.update_attribute(:opened, false)
    end
  end

  def receivers
    self.opened ?
          valid_cubacel_numbers_from_file.map{ |line| line[0,10] } :
          self.gsm_numbers.map {|gsm| gsm.number}
  end

  private
    def valid_cubacel_numbers_from_file
      IO.foreach(self.file.path).select {|line| /535[0-9]{7}/ =~ line}
    end
end
