jQuery ->
  window.loader = $('#loader')

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

  $('body').on 'click', '[data-add-term]', ->
    term = $(this).data('add-term')
    input = $('#search_q')
    if input.val().indexOf(term) == -1
      input.val(input.val() + ' AND ' + term)
    false

  setTimeout ->
    if $('.dropzone').length > 0
      dropzone = $('.dropzone')[0].dropzone
      dropzone.on 'success', (file,json)->
        if !json.valid
          messages = (attribute + ' ' + message for attribute,message of json.errors)
          this.defaultOptions.error(file, messages.join(', '))
  , 200


