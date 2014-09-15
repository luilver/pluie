class SimpleSms < ActionSmser::Base

  attr_accessor :user_id, :route_id
  attr_reader :receivers_hash
  MAX_SIZE = 160

  def multiple_receivers(receivers, message)
    dlm = message.route.gateway.name.downcase
    if ActionSmser.delivery_options[dlm.to_sym]
      #update delivery method  for this sms.
      delivery_options[:delivery_method] = "async_#{dlm}".to_sym
    end
    @receivers_hash = {}
    sms(:to => receivers, :from => "", :body => message.message,
        :type => message.class.to_s, :user => message.user.id, :route => message.route.id)
  end

  def valid?
    !body.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

  def sms_count
    #how many messages are necessary to send this sms, to 1 recipient using GSM7 encoding
    body_size = SimpleSms.message_real_length(body)
    (body_size / MAX_SIZE) + (body_size % MAX_SIZE == 0 ? 0:1)
  end

  def perform
    File.open('/tmp/delayed_job.log', "a+") do |file|
      file.write "#{ActionSmser.delivery_options[:delivery_method]} | #{self} | #{@user_id} | #{@route_id} \n"
    end
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
