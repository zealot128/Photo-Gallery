refresh_sidebar = ->
  $('body').scrollspy("refresh")
jQuery ->
  $('#file-uploader').each ->
    window.uploader = new qq.FileUploader
      element: document.getElementById('file-uploader')
      action: '/photos/upload'
      allowedExtensions: ["jpg","png","gif","jpeg"]
      params:
        'authenticity_token': $('meta[name="csrf-token"]').attr('content')
      #onComplete:(id, filename, json) ->
    $(".qq-upload-button").addClass("btn btn-primary")
  $('body').on "click" ,'.group .toggler', (bla)->
    console.log bla.target.className
    if /share_day|icon-share/.test bla.target.className
      return true
    el = $(this)
    el.toggleClass("open")
    hidden = el.parent().find(".body")
    if hidden.hasClass("unloaded")
      hidden.load("/photos/ajax_photos?id=#{el.data("id")}")
      hidden.removeClass("unloaded")
    hidden.toggle()
    refresh_sidebar()
    false
  $('.open .group .toggler').click()

  $('.photo .options .share, .toggler .share_day').fancybox
    fitToView: false
    autoSize: true
    closeClick: false
    openEffect: 'none'
    closeEffect: 'none'
    type: 'ajax'
    afterShow: ->
      element = $(".fancybox-inner form")
      element.bind "ajax:complete", (a,b)->
        $.fancybox.close()
        data = $.parseJSON b.responseText
        message = $("<div class='alert fade in alert-info'>Images added to <a href='#{data.url}'>Share</a> <a class='close' data-dismiss='alert' href='#'>&times;</a> </div>")
        $('#messages').append(message)

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
      loader = $('#loader').html()
      year_body.html(loader)
      year_body.find("#loader").show()
      $.ajax
        url: elem.attr("href")
        success: (ret) ->
          year_body.html ret
          year_body.show ->
            refresh_sidebar()
          refresh_sidebar()
        dataType: "html"

    refresh_sidebar()
    false


  $('.dropdown-toggle').dropdown()
  $('.affix').affix()

