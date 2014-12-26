class RechargePhonesService

  def initialize(api_client= nil, cashier=nil)
    @api_client = api_client
    @cashier = cashier
  end

  def execute(topups)
    api_client.subscribe(cashier, on: :topup_api_recharge_success, with: :charge)
    api_client.recharge(topups)
  end

  private
    def api_client
      @api_client ||= TopupApiService.new
    end

    def cashier
      @cashier ||= TopupCashier.default_instance
    end
end
