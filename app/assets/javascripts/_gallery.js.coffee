blueimp.Gallery.prototype.imageFactory = (obj, callback) ->
  that = this
  img = @imagePrototype.cloneNode(false)
  url = obj
  backgroundSize = @options.stretchImages
  called = undefined
  element = undefined
  callbackWrapper = (event) ->
    unless called
      event =
        type: event.type
        target: element
      # Fix for IE7 firing the load event for
      # cached images before the element could
      # be added to the DOM:
      return that.setTimeout(callbackWrapper, [event])  unless element.parentNode
      called = true
      $(img).off "load error", callbackWrapper
      if backgroundSize
        if event.type is "load"
          element.style.background = "url(\"" + url + "\") center no-repeat"
          element.style.backgroundSize = backgroundSize
      callback event
    return

  title = undefined
  if typeof url isnt "string"
    url = @getItemProperty(obj, @options.urlProperty)
    title = @getItemProperty(obj, @options.titleProperty)
  backgroundSize = "contain"  if backgroundSize is true
  backgroundSize = @support.backgroundSize and @support.backgroundSize[backgroundSize] and backgroundSize
  if backgroundSize
    element = @elementPrototype.cloneNode(false)
  else
    element = img
    img.draggable = false
  element.title = title  if title
  if options = $(obj).data('options')
    element.options = options
    $(img).data('options', options)
  $(img).on "load error", callbackWrapper
  img.src = url
  element



$ ->
  $('#blueimp-gallery').on 'slide', (event, index, slide)->
    window.current_slide = slide
    photo = $(slide).find('img').data('options')

    list = $('<dl class="clearfix"/>')
    list.append """
    <dt>Shot at:</dt><dd> #{photo.shot_at_formatted}</dd>
    <dt>Download</dt><dd>
      <a href="#{photo.original}">Full (#{photo.file_size_formatted})</a>
    </dd>
    """
    if exif = photo.exif
      if f = exif.aperture_value or f = exif.focal_length
        list.append "<dt>Aperture</dt><dd>#{f}</dd>"
      if exif.exposure_time?
        list.append "<dt>Exposure time</dt><dd>#{exif.exposure_time}</dd>"
      if exif.make? or exif.model?
        list.append "<dt>Camera</dt><dd>#{exif.make} #{exif.model}</dd>"
      if exif.iso_speed_ratings?
        list.append "<dt>ISO</dt><dd>#{exif.iso_speed_ratings}</dd>"
    actions = """
      <div class='btn-group'>
        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
          Actions <span class="caret"></span>
        </button>
        <ul class="dropdown-menu" role="menu">
          <li><a href="/photos/#{photo.id}/rotate?direction=left" data-remote='true' data-method='post'>
            <span class='fa fa-fw fa-rotate-left'></span> Rotate left</a>
          </li>
          <li><a href="/photos/#{photo.id}/rotate?direction=right" data-remote='true' data-method='post'>
            <span class='fa fa-fw fa-rotate-right'></span> Rotate right</a>
          </li>
          <li><a href="/photos/#{photo.id}/edit" class='js-modal'>
            <span class='fa fa-fw fa-edit'></span> Edit/Share</a></li>
          <li><a href="/photos/#{photo.id}" data-method='delete' data-confirm='Really delete?'>
            <span class='fa fa-fw fa-trash-o'></span> Delete</a>
          </li>
        </ul>
      </div>
    """
    $('.js-controls').html list
    $('.js-controls').append actions

$("body").on "ajax:beforeSend", -> loader.show()
$("body").on "ajax:complete", -> loader.hide()

$('body').on 'modal-changed', '#js-modal', ->
  $('#photo_shot_at').will_pickdate
    format: 'Y-m-d H:i:s',
    timePicker: true,
    militaryTime: true,
    inputOutputFormat: 'Y-m-d H:i:s'

  # disable keyboard navigation
  if gallery = $('.blueimp-gallery').data('gallery')
    if !blueimp.Gallery.prototype.onkeydown_fallback
      blueimp.Gallery.prototype.onkeydown_fallback = blueimp.Gallery.prototype.onkeydown
    blueimp.Gallery.prototype.onkeydown = -> true

# reanable keyboard navigation
$('body').on 'hidden', '.modal', ->
  if blueimp.Gallery.prototype.onkeydown_fallback
    blueimp.Gallery.prototype.onkeydown = blueimp.Gallery.prototype.onkeydown_fallback
