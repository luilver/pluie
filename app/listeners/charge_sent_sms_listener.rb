class ChargeSentSmsListener
  attr_reader :cashier

  def initialize(cashier)
    @cashier = cashier
  end

  def finish_sending_sms(sms, numbers_count,list_numbers)
    bill = Bill.find(sms.bill_id)
    bill.close_pending_sms(numbers_count,sms,list_numbers)
    if bill.closed?
      cashier.charge(sms.route_id, bill.accepted_numbers, sms.body_parts,bill.user,bill.price_numbers_accepted)
    end
  end
end
