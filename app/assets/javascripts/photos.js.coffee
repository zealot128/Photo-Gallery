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
  $('body').on "click" ,'.group .toggler', (bla)->
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
  $('.year-switch').click ->
    elem = $(this)
    year_body = elem.parent().parent().find(".year-body")
    year_body.toggle()
    if year_body.html().length == 0
      $.ajax
        url: elem.attr("href")
        success: (ret) ->
          year_body.html ret
          year_body.show()
        dataType: "html"
    false
  $('#toc').toc
    selectors: 'h2,h3'
    smoothScrolling: false
    container: '.row .span12'



