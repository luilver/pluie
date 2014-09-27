class SimpleSms < ActionSmser::Base

  attr_accessor :user_id, :route_id
  attr_reader :receivers_hash

  def pluie_sms(pluie_msg, numbers, route )
    text = ActionSmserUtils.add_info(pluie_msg.message, "#{route.user.username}:")
    delivery_options[:delivery_method] = route.dlv_to_sym
    user = route.user
    sms(to: numbers, from: user.username, body: text, type: ActionSmserUtils::PLUIE_MSG, user: user.id, route: route.id)
  end

  def multiple_receivers(receivers, message)
    if ActionSmser.delivery_options[message.route.gateway_to_sym]
      #update delivery method  for this sms.
      delivery_options[:delivery_method] = message.route.dlv_to_sym
    end
    @receivers_hash = {}
    user = message.user
    sms(:to => receivers, :from => user.username, :body => message.message,
        :type => message.class.to_s, :user => user.id, :route => message.route.id)
  end

  def valid?
    !body.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

  def perform
    self.deliver
  end

  def find_receiver_by_id(msg_id)
    @receivers_hash[msg_id]
  end

  def sms(options)
    @sms_type = options[:type]
    @user_id = options[:user]
    @route_id = options[:route]
    super(options)
  end

end
