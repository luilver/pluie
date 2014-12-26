class RechargePhonesJob < Struct.new(:topup_ids)
  def perform
    topups = Topup.find(topup_ids)
    recharge_service = RechargePhonesService.new
    recharge_service.execute(topups)
  end
end
