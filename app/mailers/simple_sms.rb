class SimpleSms < ActionSmser::Base
  include Wisper::Publisher

  attr_accessor :route_id, :bill_id, :pluie_id, :number_from, :backup_bm,:randomText
  attr_reader :receivers_hash

  def pluie_sms(text, numbers, route, bill_id )
    delivery_options[:delivery_method] = route.dlv_to_sym
    user = Bill.find(bill_id).user
    text = text + " " + (0...3).map { ('0'..'z').to_a[rand(75)] }.join
    sms(to: numbers, from: user.username, body: text,
        type: ActionSmserUtils::SYSTEM_MSG,
        route: route.id, bill_id: bill_id)
  end

  def custom(text, receivers, route, bill_id, type, message_id, randomText,number_from,backup_bm)
    if gateway_defined?(route.gateway_to_sym)
      delivery_options[:delivery_method] = route.dlv_to_sym
      #If the gateway is not defined, then it uses the default method
      #In the testing enviroment this allows to use the delivery method for all sms
    end
    user = Bill.find(bill_id).user
    text = text + " " + (0...3).map { ('0'..'z').to_a[rand(75)] }.join if randomText
    sms(:to => receivers, :from => user.username, :body => text,
        :type => type, :route => route.id,
        :bill_id => bill_id, :pluie_id => message_id.to_s,:randomText=>randomText,:number_from => number_from,:backup_bm=>backup_bm)
  end

  def valid?
    !body.blank? && !to_numbers_array.collect{|number| number.to_s.blank? ? nil : true}.compact.blank?
  end

  def perform
    self.deliver
    if  self.backup_bm==true and self.sms_type==BulkMessage.to_s
      user= Bill.find(self.bill_id).user
      if user.gateways.count>1
        gt=user.gateways.order(:price=>:asc).select{|g| g.id!=Route.find(self.route_id.to_i).gateway.id}
        list_messages={:number=>self.to.first,:message=>self.body,:user_id=>user.id,:id=>[]}
        job=BackupBulkMessageJob.new(list_messages,gt,self.randomText,self.number_from,self.pluie_id,self.to.first)
        Delayed::Job.enqueue(job,:run_at=>1.minutes.from_now)
      end
    end
  end

  def find_receiver_by_id(msg_id)
    @receivers_hash[msg_id]
  end

  #Los sms creados a partir un modelo del sistema(BulkMessage, Single.., etc)
  #deben tener como pluie_id, el id del record. Aquellos que se crean para enviar
  #notificaciones del sistema(por ejemplo a los observers) tendran como
  #id, un string fijo no numerico.
  def sms(options)
    @number_from=options[:number_from]
    @sms_type = options[:type]
    @route_id = options[:route]
    @bill_id = options[:bill_id]
    @pluie_id = options[:pluie_id] || ActionSmserUtils::SYSTEM_MSG
    @receivers_hash = {}
    super(options)
  end

  def body_parts
    ActionSmserUtils.sms_parts body
  end

  def concatenated?
    sms_encoding = SmsTools::EncodingDetection.new body
    sms_encoding.concatenated?
  end

  def broadcast_delivery_finished(successfull_numbers,list_numbers)
    publish(:finish_sending_sms, self, successfull_numbers,list_numbers)
  end
end
