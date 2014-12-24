require 'savon'

class MoleTopup
  include Wisper::Publisher
  attr_reader :username, :password, :email

  def initialize(wsdl_path = ENV['MOLE_TOPUP_API_WSDL_PATH'], user_name = ENV['MOLE_TOPUP_API_USER'], pass = ENV['MOLE_TOPUP_API_PASS'], email = ENV['MOLE_TOPUP_API_EMAIL'])
    @client = Savon.client do
      wsdl wsdl_path
      convert_request_keys_to :camelcase
    end
    @username = user_name
    @password = pass
    @email = email
  end

  def recharge(topups)
    if current_ticket
      topups.each do |tup|
        recharge_phone(current_ticket, tup)
      end
    end
  end

  def current_ticket
    @current_ticket ||= session_ticket
  end

  private
    def invalidate_ticket
      @current_ticket = nil
    end

    def recharge_phone(ticket, topup, second_attempt=false)
      msg_data = {quantity: tup.amount, phoneNumber: tup.number, ticket: ticket}
      data = call_and_fail_gracefully(:recharge_phone, msg_data)
      if data
        code, msg = get_code_and_message(data)
        case code
        when 1
          publish(:topup_api_recharge_success, tup)
        when 2..3
          if second_attempt
            error_msg = "Ticket was regenerated, but an error persist: #{msg}"
            publish(:failed_topup_api_operation, :recharge_phone, error_msg)
          else
            invalidate_ticket
            recharge_phone(current_ticket, topup, true)
          end
          publish(:topup_api_error, msg)
        when 4
          publish(:topup_api_error, msg)
        end
      end
    end

    def session_ticket
     result = nil
      response_data = call_and_fail_gracefully(:get_session_ticket,
                                            message: {username: username,
                                                      password: password,
                                                      email: email})
      if response_data
        code, msg = get_code_and_message(response_data)
        if code == 1
         result = msg
          publish(:topup_api_ticket_success, result)
        end
      end
     result
    end

    def call_and_fail_gracefully(*args, &block)
      response_data = nil
      begin
        operation = args.first
        resp_key = "#{operation}_response".to_sym
        result_key = "#{operation}_result".to_sym
        response = @client.call(*args, &block)
        if response
          response_data = response.body[resp_key][result_key]
        else
          publish(:failed_topup_api_operation, operation, "Empty response from topup api")  
        end
      rescue Savon::SOAPFault, StandardError  => e
        publish(:failed_topup_api_operation, operation, e.message)
      end
      response_data
    end

    def get_code_and_message(response_data)
      begin
        code = response_data[:code].to_i
        msg = response_data[:message]
        if code == 0
          publish(:topup_api_error, msg)
        end
      rescue StandardError => e
        publish(:failed_topup_api_operation, :read_response_data, e.message)
      end
      [code || 0, msg || ""]
    end
end
