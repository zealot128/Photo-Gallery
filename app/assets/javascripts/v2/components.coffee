
window.createGallery = (el) ->
  g = new Vue({
    el: el[0],
    data: {
      files: el.data('photos'),
      currentImage: null,
      galleryOpen: false,
      editMode: false,
      gallery: null,
    }
    methods: {
      init: ->
        window.location.hash = ''  ## gallery has problems if there is an old hash
        this.buildGallery()
        $( document ).on( "keyup", (e) => this.handleKeyboardNav(e) )

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
        KeyboardNavigation(e, this, this.gallery)

    }
    template: '#tpl-photo-gallery'
  })
  Vue.nextTick -> g.init()
  g

file = {
  props: ['file'],
  computed: {
    subHtmlId: -> "subhtml-#{this.file.id}"
    title: -> "#{this.file.caption || ""} (Shot-At: #{this.file.shot_at_formatted})"
  }
}

Vue.component('vue-photo', { mixins: [ file ], template: '#tpl-photo' })
Vue.component('vue-video', { mixins: [ file ], template: '#tpl-video' })
Vue.component('vue-photo-preview', { mixins: [ file ], template: '#tpl-photo-preview'})
Vue.component('vue-video-preview', { mixins: [ file ], template: '#tpl-video-preview'})

Vue.component('vue-edit', {
  props: ['file'],
  template: '#tpl-edit'
  data: ->
    {
      allTags: null,
      newTag: "",
      buttonText: "Save"
      tagIds: null,
    }

  ready: ->
    $(this.$el).modal('show').css({'zIndex': 10000 })
    this.tagIds = this.file.tag_ids
    this.updateTags()

  methods: {
    updateTags: ->
      Api.tags (t) => this.allTags = t

    save: ->
      hasNewTag = this.newTag? and this.newTag != ""
      filteredTags = this.allTags.filter( (tag)=> this.tagIds.indexOf(tag.id) != -1  ).map((tag) -> tag.name )
      if hasNewTag
        filteredTags.push this.newTag

      request = { tag_list: filteredTags }
      this.buttonText = "...saving"
      Api.saveImage this.file.id, request, (response)=>
        this.file.tag_ids = response.photo.tag_ids
        this.tagIds = this.file.tag_ids
        this.buttonText = "saved!"
        if hasNewTag
          this.updateTags()
          this.newTag = ""
        setTimeout =>
          this.buttonText = "Save"
        , 2000


    tagged: (tag) ->
      this.tagIds.indexOf(tag.id) != -1
    toggleTag: (tag) ->
      if this.tagged(tag)
        this.tagIds.$remove(tag.id)
      else
        this.tagIds.push(tag.id)
    closeModal: ->
      $(this.$el).modal('hide')
      setTimeout =>
        this.$parent.setEditMode(false)
      , 100
  }
})
