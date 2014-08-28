class SimpleSms < ActionSmser::Base

  attr_accessor :user_id, :route_id
  MAX_SIZE = 160

  def multiple_receivers(receivers, text, pluie_user_id, pluie_route_id, dlr_method=nil)
    if dlr_method && ActionSmser.delivery_options[dlr_method]
      #update delivery method  for this sms.
      delivery_options[:delivery_method] = dlr_method
    end
    @user_id = pluie_user_id
    @route_id = pluie_route_id
    sms(:to => receivers, :from => "", :body => text)
  end

  def valid?
    !body.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

  def sms_count
    #how many messages are necessary to send this sms, to 1 recipient using GSM7 encoding
    body_size = SimpleSms.message_real_length(body)
    count = (body_size / MAX_SIZE) + (body_size % MAX_SIZE == 0 ? 0:1)
    count
  end

  def perform
    self.deliver
  end

end
