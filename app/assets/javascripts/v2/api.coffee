
window.Api = {
  rotate: (fileId, direction, callback) ->
    $.ajax
      dataType: 'json'
      url: "/photos/#{fileId}/rotate"
      method: 'POST'
      data:
        direction: direction
      success: callback

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

  createPerson: (person_name, face_ids, unselected_face_ids, callback) ->
    $.ajax
      dataType: 'json'
      url: '/v2/assign_faces'
      method: 'POST'
      data:
        person_name: person_name
        face_ids: face_ids
        unselected_face_ids: unselected_face_ids
      success: callback

  getSimilarImages: (face, max, threshold, callback) ->
    $.ajax
      dataType: 'json'
      url: "/v2/faces/#{face.id}"
      method: 'GET'
      data:
        max: max
        threshold: threshold
      success: callback

  bulkDeleteFaces: (face_ids, callback) ->
    $.ajax
      dataType: 'json'
      url: "/v2/faces"
      method: 'DELETE'
      data:
        face_ids: face_ids
      success: callback

  getPeople: (callback) ->
    $.get '/v2/people.json', callback

  tags: (callback) ->
    $.get '/v2/tags.json', callback

  shares: (callback) ->
    $.get '/v2/shares.json', callback

  year: (year, callback) ->
    $.get "/v2/years/#{year}.json", callback
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
        el = $(vueInstance.$el).find('.js-previous-day .panel')
        if el.length > 0
          el.addClass('panel-primary').find('a img').click()
          event.preventDefault()
      when 39 # right arrow
        el = $(vueInstance.$el).find('.js-next-day .panel')
        if el.length > 0
          el.addClass('panel-primary').find('a img').click()
          event.preventDefault()
      when 32 # space
        return if $(vueInstance.$el).data('disableSpace')
        $(vueInstance.$el).find('.gallery a').first().click()
        event.preventDefault()

