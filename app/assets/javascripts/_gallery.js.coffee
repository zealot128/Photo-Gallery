window.Pics =
  gallery: -> $('.blueimp-gallery').data('gallery')
  current_item: ->
    g = Pics.gallery()
    $(g.slides[g.getIndex()]) if g?

  maybe_remove_image: (id, dom_id)->
    $(dom_id).remove()

    if id == parseInt(Pics.current_item().find('img').data('options').id)
      Pics.gallery().next()

  disable_keyboard_nav: ->
    Pics.gallery()?.options.enableKeyboardNavigation = false
  enable_keyboard_nav: ->
    Pics.gallery()?.options.enableKeyboardNavigation = true


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


blueimp.Gallery.prototype.onkeydown =  (event)->
  return if not this.options.enableKeyboardNavigation

  switch  event.which || event.keyCode
    when 13
      if (this.options.toggleControlsOnReturn)
        this.preventDefault(event)
        this.toggleControls()
    when 27
      if (this.options.closeOnEscape)
        this.close()
    when 32
      if (this.options.toggleSlideshowOnSpace)
        this.preventDefault(event)
        this.toggleSlideshow()
    when 37
      if (this.options.enableKeyboardNavigation)
        this.preventDefault(event)
        this.prev()
    when 39
      if (this.options.enableKeyboardNavigation)
        this.preventDefault(event)
        this.next()

    when 46, 68 # entf, d
      if (this.options.enableKeyboardNavigation)
        $('[data-keycode=del]').each ->
          $(this).click()

    when 84 # 't'
      $('[data-keycode=t]').each ->
        $(this).click()
      setTimeout ->
        $('#photo_tag_list').focus()
      , 150

    else




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
          <li><a href="/photos/#{photo.id}/edit" data-keycode='t' class='js-modal'>
            <span class='fa fa-fw fa-edit'></span> Edit/Share</a></li>
          <li><a href="/photos/#{photo.id}.js" data-keycode='del' data-method='delete' data-remote='true' data-confirm='Really delete?'>
            <span class='fa fa-fw fa-trash-o'></span> Delete</a>
          </li>
        </ul>
      </div>
    """
    $('.js-controls').html list
    if $('meta[name=user]').length > 0
      $('.js-controls').append actions

  $("body").on "ajax:beforeSend", -> loader.show()
  $("body").on "ajax:complete", -> loader.hide()

  #disable keyboard navigation
  $('body').on 'modal-changed', '#js-modal', Pics.disable_keyboard_nav
  $('body').on 'modal-changed', '#js-modal', ->
    $("#photo_tag_list").each ->
      me = $(this)
      me.select2(tags: me.data('values'))

    $("#photo_share_ids").select2()
    $('#photo_shot_at').datetimepicker
      format: "YYYY-MM-DD hh:mm:ss",
      weekStart: 1,
      endDate: new Date()
      todayBtn: "linked",
      language: 'de'
      calendarWeeks: true,
      todayHighlight: true

  # reanable keyboard navigation
  $('body').on 'hidden modal:closed', '.modal', Pics.enable_keyboard_nav
