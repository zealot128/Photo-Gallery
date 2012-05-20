# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  window.uploader = new qq.FileUploader
    element: document.getElementById('file-uploader')
    action: '/photos/upload'
    allowedExtensions: ["jpg","png","gif","jpeg"]
    params:
      'authenticity_token': $('meta[name="csrf-token"]').attr('content')
    onComplete:(id, filename, json) ->
      console.log json
  $('.group .toggler').click (bla)->
    if bla.target.className == "share_day"
      return true
    $(this).toggleClass("open")
    hidden = $(this).parent().find(".body")
    hidden.toggle()
    hidden.find("img.lazy").each ->
      $(this).attr("src",  $(this).data("original"))
    false

  $('.photo .options .share, .toggler .share_day').fancybox
    fitToView: false
    autoSize: true
    closeClick: false
    openEffect: 'none'
    closeEffect: 'none'
    type: 'ajax'
    afterShow: ->
      element = $(".fancybox-inner form")
      element.bind "ajax:complete", ->
        $.fancybox.close()
  $('.photo > a').fancybox
    closeBtn: false
    helpers:
      title:
        type : 'inside'
      overlay:
        opacity: 0.8
        css:
          'background-color': '#000'
      thumbs:
        width: 50
        height: 50

