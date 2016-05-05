state = {
  shares: null,
  tags: null
  updateAll: ->
    Api.tags (t) => this.tags = t
    Api.shares (t) => this.shares = t
}
window.state = state
$ ->
  $('.js-navbar').each ->
    el = this
    shares = $(el).data('shares')
    tags = $(el).data('tags')
    vm = new Vue({
      el: el,
      data: {
        state: state
        shares: shares
        tags: tags
      }
      watch: {
        state: {
          deep: true
          handler: ->
            this.shares = this.state.shares
            this.tags = this.state.tags
        }
      }
    })


window.createGallery = (el) ->
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
  props: ['file', 'state'],
  template: '#tpl-edit'
  data: ->
    {
      allTags: null
      allShares: null,
      newTag: ""
      newShare: ""
      buttonText: "Save"
      tagIds: null
      shareIds: null
    }
  watch: {
    state: {
      handler: ->
        console.log("UPDATE SHARES")
        this.allShares = this.state.shares if this.state.shares
        this.allTags = this.state.tags if this.state.tags
      deep: true
    }
  }

  ready: ->
    console.log "READY"
    state.updateAll() if !this.allTags
    $(this.$el).modal('show').css({'zIndex': 10000 })
    this.tagIds = this.file.tag_ids
    this.shareIds = this.file.share_ids

  methods: {
    save: ->
      hasNewTag = this.newTag? and this.newTag != ""
      filteredTags = this.allTags.filter( (tag)=> this.tagIds.indexOf(tag.id) != -1  ).map((tag) -> tag.name )
      if hasNewTag
        filteredTags.push this.newTag

      request = { tag_list: filteredTags, share_ids: this.shareIds, new_share: this.newShare }
      this.buttonText = "...saving"
      Api.saveImage this.file.id, request, (response)=>
        this.file.tag_ids = response.photo.tag_ids
        this.file.share_ids = response.photo.share_ids
        this.tagIds = this.file.tag_ids
        this.shareIds = this.file.share_ids
        this.buttonText = "saved!"
        state.updateAll()
        if hasNewTag
          this.newTag = ""
        if this.newShare? and this.newShare != ""
          this.newShare = ""
        setTimeout =>
          this.closeModal()
        , 200


    tagged: (tag) -> this.tagIds.indexOf(tag.id) != -1
    hasShare: (share) -> this.shareIds.indexOf(share.id) != -1
    toggleTag: (tag) ->
      if this.tagged(tag)
        this.tagIds.$remove(tag.id)
      else
        this.tagIds.push(tag.id)
    toggleShare: (share) ->
      if this.hasShare(share)
        this.shareIds.$remove(share.id)
      else
        this.shareIds.push(share.id)
    closeModal: ->
      console.log 'CLOSING MODAL'
      $(this.$el).modal('hide')
      setTimeout =>
        this.$parent.setEditMode(false)
      , 100
  }
})
