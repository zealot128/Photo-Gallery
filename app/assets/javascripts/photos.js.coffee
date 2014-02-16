jQuery ->
  window.loader = $('#loader')
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
    if /share_day|fa-share/.test bla.target.className
      return true
    el = $(this)
    el.toggleClass("open")
    hidden = el.parent().find(".body")
    if hidden.hasClass("unloaded")
      loader.show()
      hidden.load "/photos/ajax_photos?id=#{el.data("id")}", ->
        loader.hide()
      hidden.removeClass("unloaded")
    hidden.toggle()
    false

  $('.open .group .toggler').click()


  $('.js-year-switch').click ->
    elem = $(this)
    year_body = elem.parent().parent().find('.year-body')
    year_body.toggle()
    if year_body.html().length == 0
      loader.show()
      $.ajax
        url: elem.attr("href")
        success: (ret) ->
          year_body.html ret
          year_body.show()
          loader.hide()
        dataType: "html"
    false

  $('.remove-share').click ->
    elem = $(this)
    $.ajax
      url: elem.attr("href")
      type: "post"
      complete: (ret) ->
        elem.closest(".photo").remove()
    false

  $('.dropdown-toggle').dropdown()



