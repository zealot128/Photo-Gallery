# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('.group .toggler').click ->
    $(this).toggleClass("open")
    hidden = $(this).parent().find(".body")
    hidden.toggle()
    hidden.find("img.lazy").each ->
      $(this).attr("src",  $(this).data("original"))
    false
