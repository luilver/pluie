$(document).on('ready, page:change', function () {
    $(".user_for_dlr_select").select2().on('change', function(){
        $('#dlrs_user_' + $(this).val())[0].click();
    });
});
