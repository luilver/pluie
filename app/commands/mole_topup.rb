require 'savon'

class MoleTopup
  include Wisper::Publisher
  attr_reader :client

  def initialize(wsdl_path = ENV['MOLE_TOPUP_API_WSDL_PATH'], user = ENV['MOLE_TOPUP_API_USER'], pass = ENV['MOLE_TOPUP_API_PASS'], email = ENV['MOLE_TOPUP_API_EMAIL'])
    @client = Savon.client do
      wsdl wsdl_path
      convert_request_keys_to :camelcase
    end
    @user = user
    @password = pass
    @email = email
  end

  def recharge(user, *number_amount_pairs)
  end

  def session_ticket

  end

  private

end
