require_relative 'async_routesms'

module ActionSmser::DeliveryMethods
  class AsyncRoutesms1 < AsyncRoutesms
    @base_url = "http://smpp2.routesms.com:8080/"
    @gateway_key = :routesms1
    #las diferencias aqui son a que endpoint(url) se envia y con que credencial.
    #basta con definir el gateway_key apropiadamente, para cargar las credenciales
    #y modificar el base url.
  end
end
