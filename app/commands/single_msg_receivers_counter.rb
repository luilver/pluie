class SingleMsgReceiversCounter
  def self.count(single_message)
    single_message.gsm_numbers.any? ?
                                  single_message.gsm_numbers.count :
                                  single_message.valid_gsm_numbers_from_field.count
  end
end
