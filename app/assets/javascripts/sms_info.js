$(document).ready( function(){
    var $size = $('#sms_size');
    var $parts = $('#sms_parts');

    var $text_area = $('#single_message_message') || $('#bulk_message_message');
    $text_area.keyup( function(){
        message = new SmsTools.Message(this.value);
        $size.text(message.length);
        $parts.text(message.concatenatedPartsCount);
    })
});
