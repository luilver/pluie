class SmsProcessor
  attr_reader :cashier

  def initialize(cashier)
    @cashier = cashier
  end

  def finish_sending_sms(sms, numbers_count)
    bill = Bill.find(sms.bill_id)
    bill.close_pending_sms(numbers_count)
    if bill.closed?
      cashier.charge(sms.route_id, bill.accepted_numbers, sms.body_parts)
    end
  end
end
