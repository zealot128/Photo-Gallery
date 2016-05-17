file = {
  props: ['file'],
  computed: {
    subHtmlId: -> "subhtml-#{this.file.id}"
    title: -> "#{this.file.caption || ""} (Shot-At: #{this.file.shot_at_formatted})"
  }
}

video = {
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
