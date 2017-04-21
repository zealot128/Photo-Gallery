file = {
  props: ['file'],
  data: ->
    showFaces: false
    image_width: 0
    image_height: 0
  methods: {
    undoDelete: () ->
      Api.undeleteImage(this.file.id)
      alert("Image restored. Reload page to reflect trash - sorry too lazy to implement proper")

    like: ($event) ->
      Api.like(this.file.id)
      $event.preventDefault()
      $event.stopPropagation()
      this.file.liked_by = Array.concat(this.file.liked_by, currentUser)
      this.$forceUpdate()

    unlike: ($event) ->
      Api.unlike(this.file.id)
      $event.preventDefault()
      $event.stopPropagation()
      index = this.file.liked_by.indexOf(currentUser)
      if index != -1
        this.file.liked_by.splice(index, 1)

    toggleFaces: ()->
      this.showFaces = !this.showFaces
      img = $('.lg-current .lg-image')
      this.image_width = img.width()
      this.image_height = img.height()
      Vue.nextTick =>
        if this.showFaces
          bbs = $(this.$el).find('.js-bbs').html()
          img.parent().append(bbs).css({
            position: 'relative',
            display: 'inline-block',
            maxWidth: this.image_width
            maxHeight: this.image_height
          })
        else
          img.parent().find('.bb-face').remove()
          img.parent().append(bbs).attr('style', '')
  },
  computed: {
    liked: -> this.file.liked_by.indexOf(currentUser) != -1
    subHtmlId: -> "subhtml-#{this.file.id}"
    title: -> "#{this.file.caption || ""} (Shot-At: #{this.file.shot_at_formatted})"
    faces_count: -> this.file.faces.length
    unassigned_faces_count: ->
      faces = this.file.faces.filter((el)-> !el.person_id )
      faces.length
  }
}

video = {
  mounted: ->
    this.resetFrame()
  data: ->
    currentFrame: null
    currentFrameIndex: 0
    mouseIsOver: false
  methods:
    resetFrame: ->
      this.currentFrame = this.file.versions.preview
      this.currentFrameIndex = 0
    onMouseOver: (e)->
      this.mouseIsOver = true
      this.frame()
    onMouseOut: (e)->
      this.mouseIsOver = false
      this.resetFrame()

    frame: ->
      return unless this.mouseIsOver
      next_image = this.file.thumbnails[this.currentFrameIndex]
      if next_image
        this.currentFrame = next_image
        this.currentFrameIndex += 1
      else
        this.resetFrame()
      that = this
      setTimeout ->
        that.frame()
      , 500

  computed: {
    duration: ->
      sec_num = this.file.exif.duration
      return "" if !sec_num?
      hours   = Math.floor(sec_num / 3600)
      minutes = Math.floor((sec_num - (hours * 3600)) / 60)
      seconds = sec_num - (hours * 3600) - (minutes * 60)
      if hours   < 10
        hours   = "0"+hours
      if minutes < 10
        minutes = "0"+minutes
      if seconds < 10
        seconds = "0"+seconds
      if hours > 0
        hours+':'+minutes+':'+seconds
      else
        minutes+':'+seconds
  }
}

Vue.component('vue-photo', { mixins: [ file ], template: '#tpl-photo' })
Vue.component('vue-video', { mixins: [ file, video ], template: '#tpl-video' })
Vue.component('vue-photo-preview', { mixins: [ file ], template: '#tpl-photo-preview'})
Vue.component('vue-video-preview', {
  mixins: [ file, video ],
  template: '#tpl-video-preview',
})

$(document).on('click', '.js-toggle-faces', (e)->
  e.preventDefault()
  vueInstance = $("#" + $(this).parent().parent()[0].dataset.id)[0].__vue__
  vueInstance.toggleFaces()
)
$(document).on('click', '.js-undelete', (e)->
  e.preventDefault()
  vueInstance = $("#" + $(this).closest('p')[0].dataset.id)[0].__vue__
  vueInstance.undoDelete()
)
