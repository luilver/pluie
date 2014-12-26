class RechargePhonesJob < Struct.new(:topup_ids)
  def perform
    topups = Topup.find(topup_ids)
    RechargePhonesService.execute(topups)
  end
end
