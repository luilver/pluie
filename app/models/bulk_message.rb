require 'delayed_job'
require 'set'

class BulkMessage < Message
  has_and_belongs_to_many :lists
  validates :lists, presence: true

  def receivers
    set = Set.new
    self.lists.each do |list|
      set.merge list.receivers
    end
    set.to_a
  end

  def deliver
    begin
      dlr_method = self.route.gateway.name
      numbers = receivers.to_a
      size = [(numbers.size * ActionSmser.delivery_options[:numbers_from_bulk]).to_i, ActionSmser.delivery_options[:min_numbers_in_sms]].max
      batches = numbers.each_slice(size).to_a
      bill = Bill.create(number_of_sms: batches.size, message_id: self.pluie_message_id, user: self.user)
      batches.each_with_index do |nums, index|
        sms = SimpleSms.multiple_receivers(nums, self, bill.id)
        Delayed::Job.enqueue(sms, :priority => bulk_sms_priority(index), :queue => bulk_sms_queue)
    end
    rescue StandardError => e
      Rails.logger.info "Error on deliver. BulkMessage #{self.id}. #{e.message}"
    end
  end

  def gsm_numbers
    set = Set.new
    self.lists.each do |list|
      set.merge list.gsm_numbers
    end
    set.to_a
  end

  def gsm_numbers_count
    #TODO. ver que esto sea mas eficiente.
    #si los gsm_numbers se asocian a la lista con DJ, puede darse el caso de que no
    #esten todos relacionados con  lista cuando se intenta enviar el mensaje.
    #Esto es significativo, pues una de las validaciones  implica contar la cantidad
    #de destinatarios para ver si el balance del usuario es suficiente.
    receivers.size
  end
end
