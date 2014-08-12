class SimpleSms < ActionSmser::Base

  attr_accessor :user_id

  def multiple_receivers(receivers, text, pluie_user_id, dlr_method=nil)
    if dlr_method && ActionsSmser.delivery_options[dlr_method]
      #update delivery method  for this sms.
      delivery_options[:delivery_method] = dlr_method
    end
    @user_id = pluie_user_id
    sms(:to => receivers, :from => "", :body => text)
  end

  def valid?
    !body.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

end
