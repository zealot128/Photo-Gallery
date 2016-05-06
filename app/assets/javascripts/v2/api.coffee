
window.Api = {
  bulkUpdate: (request, callback, error) ->
    $.ajax
      dataType: 'json'
      url: '/v2/bulk_update'
      method: 'POST'
      data: request
      success: (e) ->
        callback(e)
      complete: (e)->
        error(e) if error
  saveImage: (id, attributes, callback, error) ->
    $.ajax
      dataType: 'json'
      url: "/photos/#{id}"
      data:
        photo: attributes
      method: 'PATCH'
      success: (e)->
        callback(e)
      complete: (e)->
        error(e) if error

  deleteImage: (id, callback)->
    if !id?
      callback()
      return
    url = "/photos/#{id}"
    $.ajax
      url: "/photos/#{id}"
      dataType: "json"
      method: "DELETE"
      success: (e) ->
        callback(e) if callback

  tags: (callback) ->
    $.get '/v2/tags.json', callback

  shares: (callback) ->
    $.get '/v2/shares.json', callback
}


window.KeyboardNavigation = (event, vueInstance, gallery)->
  if vueInstance.editMode
    switch event.which
      when 27 # esc
        event.preventDefault()
        event.stopPropagation()
        vueEdit = vueInstance.$children.filter((e)->  e.constructor.name == 'VueEdit' )[0]
        if vueEdit?
          vueEdit.closeModal()

  else if vueInstance.galleryOpen
    switch event.which
      when 68, 46 # d, delete #delete image
        if confirm("Really delete image?")
          vueInstance.deleteImage(gallery)
          event.preventDefault()
      when 69 # e
        vueInstance.editImage(gallery)
        event.preventDefault()
  else
    switch event.which
      when 37 # left arrow
        $(vueInstance.$el).find('.js-previous-day .panel').addClass('panel-primary').find('a img').click()
        event.preventDefault()
      when 39 # right arrow
        $(vueInstance.$el).find('.js-next-day .panel').addClass('panel-primary').find('a img').click()
        event.preventDefault()
      when 32 # space
        $(vueInstance.$el).find('.gallery a').first().click()
        event.preventDefault()
