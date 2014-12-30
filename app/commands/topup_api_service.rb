require 'savon'

class TopupApiService
  include Wisper::Publisher
  attr_reader :username, :password, :email

  def initialize(wsdl_path = ENV['MOLE_TOPUP_API_WSDL_PATH'], user_name = ENV['MOLE_TOPUP_API_USER'], pass = ENV['MOLE_TOPUP_API_PASS'], email = ENV['MOLE_TOPUP_API_EMAIL'])
    options = {
      env_namespace: :soap, #Add 'soap:' to Envelope & Body tags
      element_form_default: :unqualified #remove 'tns:' from fields, ex username, password, etc
    }
    @client = Savon.client(options) do
      wsdl wsdl_path
    end
    @username = user_name
    @password = pass
    @email = email
  end

  def recharge(topups)
    unless topups.respond_to? :each
      topups = [topups]
    end
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
      msg_data = {quantity: topup.amount, phoneNumber: topup.number, ticket: ticket}
      data = call_and_fail_gracefully(:recharge_phone, msg_data)
      if data
        code, msg = get_code_and_message(data)
        case code
        when 1
          publish(:topup_api_recharge_success, topup)
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
                                              {username: username,
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

    #The request built by savon is not exactly the same that
    #the one expected by the api. In particular savon appends
    #tns: prefix to some tags(operation tag and data fields)
    #it also miss the xmlns attribute in the operation tag
    #I don't know if there is a missing configuration for savon or what
    #Anyway, i came up with this hack to fix the request
    def build_custom_message(operation_name, op_data)
      body = @client.build_request(operation_name, op_data).body
      soap_xml_tag = operation_name.to_s.camelcase
      result = remove_tns_prefix(soap_xml_tag, body)
      result = insert_xmlns_attribute(soap_xml_tag ,result)
      result
    end

    def remove_tns_prefix(soap_xml_tag, request_body)
      request_body.gsub("tns:#{soap_xml_tag}", soap_xml_tag)
    end

    def insert_xmlns_attribute(soap_xml_tag, request_body)
      request_body.gsub("<#{soap_xml_tag}>", "<#{soap_xml_tag} xmlns=\"http://tempuri.org/\">")
    end

    def call_and_fail_gracefully(operation, op_data)
      response_data = nil
      begin
        msg = build_custom_message(operation, message: op_data)
        response = @client.call(operation, xml: msg)
        if response
          resp_key = "#{operation}_response".to_sym
          result_key = "#{operation}_result".to_sym
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
