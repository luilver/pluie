# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).on "page:change", ->
  $('#message_join').on('input propertychange', ->
    message = new SmsTools.Message(this.value+'    ')

    $('#sms_size').text(message.length)
    $('#sms_parts').text(message.concatenatedPartsCount)
  )
  $('#list_ids').select2({
    placeholder: $('#list_ids').data('phtext')
  })


