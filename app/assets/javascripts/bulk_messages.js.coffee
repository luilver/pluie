# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:change", ->
  $('#bulk_message_message').on('input propertychange', ->

    enteredText = this.value
    numberOfLineBreaks = (enteredText.match(/\n/g)||[]).length;
    #characterCount = enteredText.length + numberOfLineBreaks;
    k='';
    i=0
    while i < numberOfLineBreaks
       i=i+1
       k=k+' '

    message = new SmsTools.Message(this.value+'    '+k)

    $('#sms_size').text(message.length)
    $('#sms_parts').text(message.concatenatedPartsCount)
  )
  $('#list_ids').select2({
    placeholder: $('#list_ids').data('phtext')
  })

  $('#name_route').select2({
    placeholder: $('#name_route').data('phtext')
  })
  $('#gateway_q').select2({
    placeholder: $('#gateway_q').data('phtext')
  })
  $('#cco_q').select2({
    placeholder: $('#cco_q').data('phtext')
  })
  $('#route_q').select2({
    placeholder: $('#route_q').data('phtext')
  })
  $('#mask_user_id').select2({
    placeholder: $('#mask_user_id').data('phtext')
  })
  $('#user_id_historic').select2({
    placeholder: $('#user_id_historic').data('phtext')
  })
