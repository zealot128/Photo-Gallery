#= require vue


createGallery = (el) ->
  new Vue({
    el: el[0],
    data: {
      files: el.data('photos'),
      currentImage: null,
      gallery: null,
    }
    events: {
      'start-gallery': (clickedImage) ->
        window.location.hash = ''  ## gallery has problems if there is an old hash
        this.gallery ||= $(this.$el).lightGallery().data('lightGallery')
        index = this.files.findIndex (i)->  i == clickedImage
        if !$('body').hasClass('lg-on')
          this.gallery.build(index)
          $('body').addClass('lg-on')
    }
    template: '#tpl-photo-gallery'
  })

files = {
  props: ['file'],
  computed: {
    subHtmlId: -> "subhtml-#{this.id}"
    title: ->
      "#{this.caption} (Shot-At: #{this.shot_at_formatted})"
  },
  methods: {
    imageClick: (event)->
      event.preventDefault()
      event.stopPropagation()
      this.$dispatch('start-gallery', this.file)
  },
}

VuePhoto = Vue.extend(
  mixins: [ files ]
  template: '#tpl-photo'
)
VueVideo = Vue.extend(
  mixins: [ files ]
  template: '<div>VIDEO!</div>'
)
Vue.component('vue-photo', VuePhoto)
Vue.component('vue-video', VueVideo)


$ ->
  $('.js-photo-gallery').each ->
    el = $(this)
    createGallery( el )

