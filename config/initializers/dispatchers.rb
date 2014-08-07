#require 'dispatchers/nexmo_http'
require 'delivery_methods/dispatchers/infobip'
require 'delivery_methods/dispatchers/smpp_dispatcher'

#infobip -> oneapi
INFOBIP_KEY = ENV['INFOBIP_KEY']
INFOBIP_PASS = ENV['INFOBIP_PASS']

#nexmo -> enabled for smpp use
NEXMO_KEY = ENV['NEXMO_API_KEY']
NEXMO_PASS = ENV['NEXMO_API_SECRET']
