class SimpleSms < ActionSmser::Base

  attr_accessor :user_id, :route_id, :bill_id
  attr_reader :receivers_hash

  def pluie_sms(text, numbers, route )
    delivery_options[:delivery_method] = route.dlv_to_sym
    user = route.user
    sms(to: numbers, from: user.username, body: text, type: ActionSmserUtils::PLUIE_MSG, user: user.id, route: route.id)
  end

  def custom(text, receivers, route, bill_id, type)
    if gateway_defined?(route.gateway_to_sym)
      delivery_options[:delivery_method] = route.dlv_to_sym
    end
    @receivers_hash = {}
    user = route.user
    sms(:to => receivers, :from => user.username, :body => text,
        :type => type, :user => user.id, :route => route.id,
        :bill_id => bill_id)
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
    @bill_id = options[:bill_id]
    super(options)
  end

  def body_parts
    ActionSmserUtils.sms_parts body
  end

  def concatenated?
    sms_encoding = SmsTools::EncodingDetection.new body
    sms_encoding.concatenated?
  end

end
