require_relative 'async_routesms'

module ActionSmser::DeliveryMethods
  class AsyncRoutesms1 < AsyncRoutesms
    @path_url = "bulksms/bulksms"
    @base_url = "http://smpp2.routesms.com:8080/"
    @gateway_key = :routesms1
    #En el caso de Routesms, se tienen dos cuentas distintas, que
    #utilizan url diferentes. Basta con definir el gateway_key
    #apropiadamente, para cargar las credenciales correctas,
    #y modificar la url a donde se envian los requests.
    #Para parsear la respuesta de DLR, se puede utilizar una sola de las
    #clases pues en ese caso no importa con que credenciales, ni a que
    #endpoint se envio el mensaje
  end
end
