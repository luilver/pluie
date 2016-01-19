class BulkDeliverer

  def self.deliver(message, randomText=true)
    text = message.message
    route = message.route
    type = message.pluie_type
    numbers = message.receivers.to_a
    size = batch_size(numbers.size)
    size = 1
    batches = numbers.each_slice(size).to_a
    bill = Bill.create(number_of_sms: batches.size, message_id: message.pluie_message_id, user: message.user)
    batches.each_with_index do |nums, index|
      sms = SimpleSms.custom(text, nums, route, bill.id, type, message.id, randomText)
      Delayed::Job.enqueue(sms, :priority => bulk_sms_priority(index), :queue => bulk_sms_queue)
    end
  end

  private

    def self.numbers_in_sms
      ActionSmser.delivery_options[:min_numbers_in_sms]
    end

    def self.bulk_size_fraction
      ActionSmser.delivery_options[:numbers_from_bulk]
    end

    def self.batch_size(total_size)
      [(total_size * bulk_size_fraction).to_i,
        numbers_in_sms].max
    end

end
