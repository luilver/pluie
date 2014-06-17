module SmsApi

    module ClassMethods

    end

    module InstanceMethods

      #TODO add threading

      def set_sms_dispatcher
        #crea la variable en el controller, a traves de la cual se enviaran los mensajes
        #la idea seria, ejecutar este metodo en cada controller que envie mensajes y luego
        #con los metodos de instancia del modulo SmsApi, se envian los mensajes
        #
        #ahora solo esta la implementacion de Nexmo,...
        #en general, segun la ruta o proveedor que escoja el usuario, se instancia
        #la  clase correspondiente.
        @dispatcher =  NexmoApi.new { |response| puts "hello from nexmo response"}
      end

      def send_message( single_msg)
        #envia un mensaje a los numeros que tiene asociados.
        # el texto del mensaje esta dado por la propiedad message

        begin
          if single_msg.gsm_numbers.count == 1
            @dispatcher.send_single_message(single_msg.gsm_numbers.first.number, single_msg.message)
          else
            @dispatcher.send_multiple_messages(single_msg.gsm_numbers.map { |n| n.number  }, single_msg.message)
          end
        rescue Exception => e
          puts "<<<<<<<<<<<<<<<<<<<<< #{e.message} >>>>>>>>>>>>>>>>>>>"
          #TODO... log errors here
        end

      end
      handle_asynchronously :send_message

      def send_bulk(bulk_msg)
      end
      handle_asynchronously :send_bulk, :queue =>'bulk'

    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end

    class NexmoApi
      def initialize(&on_response)
        @nexmo = Nexmo::Client.new(key = ENV['NEXMO_API_KEY'], secret = ENV['NEXMO_API_SECRET'],  &on_response)
      end

      def send_single_message(to, text)
        response = @nexmo.send_message({:to => to, :text => text})
      end

      def send_multiple_messages(numbers, text)

        numbers.each do |number|
          @nexmo.send_message({:to => number, :text => text})
        end
      end

    end

    class  ResponseProvider
      def initialize(&on_response)
        @response_block = on_response
      end

      protected
        def decode_response(api_response)
          @response_block ? @response_block.call(api_response) : api_response
        end

    end

    class ClockWorksApi < ResponseProvider
      def initialize(&on_response)
        super(&on_response)
        @api = Clockwork::API.new(ENV['TEST_CLOCKWORKS_KEY'])
      end

      def send_single_message(to, text)
        #to The phone number to send the SMS to in international number format (without a leading + or international dialling prefix such as 00, e.g. 441234567890).
        message = @api.messages.build(:to => to, :content => text)
        response = message.deliver

        #TODO ver si se implementa un objeto response custom, que agrupe las funcionalidades de cada provider
        decode_response(response)

      end

      def send_multiple_messages(numbers, text)

        numbers.each do |n|
          api.messages.build({:to => n, :content => text})
        end

        responses = api.deliver_messages
        responses.each do |response|
          decode_response response
        end
      end

    end
end
