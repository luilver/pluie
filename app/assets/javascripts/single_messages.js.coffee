# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:change", ->
    $('#single_message_message').on('input propertychange', ->
        message = new SmsTools.Message(this.value)
        $('#sms_size').text(message.length + 4)
        $('#sms_parts').text(Math.floor((message.length+4)/161+1))
    )
