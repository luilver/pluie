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
      numbers = IO.foreach(self.file.path).map{ |line| GsmNumber.find_or_create_by(number: line[0,10]) }
      from_file = Set.new(numbers)
      new_numbers = from_file - self.gsm_numbers.to_a
      self.gsm_numbers << new_numbers.to_a
    end
  end

  def remove_numbers
    if self.file.path
      numbers = IO.foreach(self.file.path).map{ |line| GsmNumber.find_by_number(line[0,10]) }
      from_file = Set.new(numbers)
      erase_this = from_file & self.gsm_numbers.to_a
      self.gsm_numbers.delete(erase_this.to_a)
    end
    #IO.foreach(self.file.path) { |line| n = GsmNumber.find_by_number(line[0,10]);
     #                             self.gsm_numbers.delete(n) if self.gsm_numbers.include?(n)  } if self.file.path
  end

  def receivers
    return self.file.path ? IO.foreach(self.file.path).map{ |line| line[0,10] } : []
  end
  #TODO.... en receivers utilizar los numeros GSM asociados a lista, si esta no esta siendo modificada.

end
