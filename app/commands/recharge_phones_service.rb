class RechargePhonesService
  def self.execute(topups, api_client= TopupApiService.new, cashier=  TopupCashier.default_instance)
    api_client.subscribe(cashier, on: :topup_api_recharge_success, with: :charge)
    api_client.recharge(topups)
  end
end
