window.Gallery = (domEl, state) ->
  el = $(domEl)
  recent = window.location.pathname.indexOf('/recent') != -1

  g = new Vue({
    el: el[0],
    data: {
      state: state,
      files: el.data('photos'),
      currentImage: null,
      galleryOpen: false,
      editMode: false,
      isRecentGallery: recent,
      gallery: null,
    }

    mounted: ->
      window.location.hash = ''  ## gallery has problems if there is an old hash
      this.buildGallery()
      $( document ).on( "keyup", (e) => this.handleKeyboardNav(e) )
      if this.isRecentGallery && window.App
        App.new_uploads.received = (data)=>
          this.files.unshift({})
          Vue.set(this.files, 0, data.file)

    methods: {
      buildGallery: ->
        lgOptions = {
          selector: '.gallery-element',
          showThumbByDefault: false
          videojs: true
        }
        $el = $(this.$el).find('.gallery')
        this.gallery = $el.lightGallery(lgOptions).data('lightGallery')
        $el.on('onBeforeOpen.lg', => this.galleryOpen = true)
        $el.on('onCloseAfter.lg', => this.galleryOpen = false)

      editImage: (gallery)->
        this.currentImage = this.files[gallery.index]
        this.setEditMode(true)

      setEditMode: (value)->
        this.editMode = value
        this.savedCallbacks ||= {}
        if value
          this.savedCallbacks.nextSlide = this.gallery.goToNextSlide
          this.savedCallbacks.prevSlide = this.gallery.goToPrevSlide
          this.gallery.goToNextSlide = -> true
          this.gallery.goToPrevSlide = -> true
          this.gallery.s.escKey = false
        else
          this.gallery.s.escKey = true
          this.gallery.goToNextSlide = this.savedCallbacks.nextSlide
          this.gallery.goToPrevSlide = this.savedCallbacks.prevSlide

      handleKeyboardNav: (e)->
        if currentUser
          KeyboardNavigation(e, this, this.gallery)
    }
    template: '#tpl-photo-gallery'
  })
  g
  el.data('gallery', g)
