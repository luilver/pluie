require "test_helper"

class MakeTopupTest < Capybara::Rails::TestCase
  include Warden::Test::Helpers
  Warden.test_mode!

  setup do
    @user = users(:two)
    login_as(@user, scope: :user)
    Capybara.current_driver = :webkit
    WebMock.allow_net_connect!

    ticket = stub_soap_response(:get_session_ticket)
    recharge_response = stub_soap_response(:recharge_phone)
    Savon::Client.any_instance.expects(:build_request).at_least_once.returns(stub(body: ""))
    Savon::Client.any_instance.expects(:call).with(:get_session_ticket, {xml: ""}).returns(ticket)
    Savon::Client.any_instance.expects(:call).with(:recharge_phone, {xml: ""}).returns(recharge_response)
  end

  teardown do
    Warden.test_reset!
  end

  test "recharge phone" do
    amount = (10..50).step(5).to_a.sample
    expected_balance = @user.balance - TopupCashier.new.price_strategy.calculate_price_by_amount(amount)
    visit new_topup_path

    within('.new_topup') do
      fill_in("topup_number", with: cubacel_random_number)
      select(amount.to_s, from: "topup_amount")

      within('.actions') do
        find("input[type='submit']").click
      end
    end

    #HACKY STUFF!!!!
    #Se recarga la pagina para que se modifique el balance del usuario.
    #Este disminuye en otro hilo(Celluloid Actor), si se usa async: true
    #al hacer broadcast en Wisper y notificar al cliente soap
    visit page.current_path
    #HACKY STUFF!!!!
    find('.user_balance').must_have_content expected_balance.to_s
  end
end
