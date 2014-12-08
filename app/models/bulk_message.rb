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
    MessageProcessor.deliver(self, BulkDeliverer, DeliveryNotifier)
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
