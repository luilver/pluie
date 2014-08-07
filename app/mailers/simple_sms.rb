class SimpleSms < ActionSmser::Base
  def multiple_receivers(receivers, text, dlr_method=nil)
    if dlr_method && ActionsSmser.delivery_options[dlr_method]
      #update delivery method  for this sms.
      delivery_options[:delivery_method] = dlr_method
    end
    sms(:to => receivers, :from => "", :body => text)
  end

end
