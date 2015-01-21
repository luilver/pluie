# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "page:change", ->
    toggle_numbers = $("#toggle_numbers")
    numbers = $("#numbers")
    toggle_numbers.click ->
        numbers.toggle()
        if numbers.css('display') == 'block'
            text = toggle_numbers.data("hide")
        else
            text = toggle_numbers.data("show")
        toggle_numbers.text(text)
