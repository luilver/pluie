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

  $('#prefix_list').select2({
    placeholder: $('#prefix_list').data('phtext')
  })
