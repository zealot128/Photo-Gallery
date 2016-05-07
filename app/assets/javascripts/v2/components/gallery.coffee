window.Gallery = (domEl, state) ->
  el = $(domEl)
  g = new Vue({
    el: el[0],
    data: {
      state: state,
      files: el.data('photos'),
      currentImage: null,
      galleryOpen: false,
      editMode: false,
      gallery: null,
    }

    ready: ->
      window.location.hash = ''  ## gallery has problems if there is an old hash
      this.buildGallery()
      $( document ).on( "keyup", (e) => this.handleKeyboardNav(e) )

    methods: {
      buildGallery: ->
        lgOptions =  {
          selector: '.gallery-element',
          videojs: true
        }
        $el = $(this.$el).find('.gallery')
        this.gallery = $el.lightGallery(lgOptions).data('lightGallery')
        $el.on('onBeforeOpen.lg', => this.galleryOpen = true)
        $el.on('onCloseAfter.lg', => this.galleryOpen = false)
        $el.on('deleteImage.lg', (a,b)=> this.deleteImage(b))
        $el.on('editImage.lg', (a,b) => this.editImage(b))

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

      deleteImage: (gallery)->
        file = this.files[gallery.index]
        return if !file?
        Api.deleteImage(file.id)
        index = gallery.index
        item_count = gallery.$items.length
        gallery.destroy(true)
        this.files.$remove(file)
        that = this
        Vue.nextTick ->
          if item_count > 1
            elements = $(that.$el).find('.gallery-element')
            newIndex = Math.min(elements.length - 1, index)
            that.buildGallery()
            setTimeout ->
              $(elements.get(newIndex)).click()
            , 200
      handleKeyboardNav: (e)->
        if currentUser
          KeyboardNavigation(e, this, this.gallery)
    }
    template: '#tpl-photo-gallery'
  })
  g
