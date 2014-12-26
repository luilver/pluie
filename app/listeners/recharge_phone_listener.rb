class RechargePhoneListener
  def topup_created(topup)
    multiple_topups_created([topup])
  end

  def multiple_topups_created(topups)
    ids = topups.map { |t| t.id  }
    Delayed::Job.enqueue(RechargePhonesJob.new(ids), queue: 'topups')
  end
end
