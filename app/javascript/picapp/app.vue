<template lang="pug">
  #app
    //p {{message}}
    //i(class="mdi mdi-bell")
    .gallery-container(v-if='photos.length > 0')
      v-gallery(:images="photos" :index="galleryControlIndex" @close="galleryControlIndex = null" ref='gallery' @onslide='onSlide')
        div(slot='controls'): .gallery-controls(v-if='currentFile')
          info-bar(:current-file='currentFile' @delete='removeCurrentFile' @fullscreen='toggleFullscreen')

      .gallery-element(v-for='(image, imageIndex) in photos' :key='image.id')
        photo-preview(v-if='image.data.type == "Photo"' :image='image' @click='galleryControlIndex = imageIndex')
        video-preview(v-if='image.data.type == "Video"' :video='image' @click='galleryControlIndex = imageIndex')
</template>

<script>
import VGallery from 'picapp/VGallery';
import 'blueimp-gallery/css/blueimp-gallery-video.css';
import PhotoPreview from 'picapp/components/photo-preview';
import VideoPreview from 'picapp/components/video-preview';
import InfoBar from 'picapp/components/info-bar';

class UploadedFile {
  constructor(data) {
    this.data = data;
    this.title = data.shot_at_formatted
    this.href = data.versions.large
    this.preview = data.versions.preview
    if (data.type == 'Video') {
      this.type = 'video/mp4'
      this.poster = this.preview
    } else {
      this.type = 'image/jpeg'
      this.thumbnail = data.versions.thumb
    }
  }
}

export default {
  components: { VGallery, PhotoPreview, VideoPreview, InfoBar },
  data() {
    return {
      galleryIndex: -1,
      galleryControlIndex: -1,
      currentFile: null,
      photos: [],
      pagination: {
        currentPage: 1,
        totalPages: 1,
        totalCount: 0
      },
    }
  },
  created() {
    this.$http.get('/v3/api/photos', {
    }).then(r => {
      this.photos = r.data.data.map(d => new UploadedFile(d))
      this.pagination.currentPage = 1
      this.pagination.totalPages = r.data.meta.total_pages
      this.pagination.totalCount = r.data.meta.total_count
    }).catch(error => {
      console.error(error)
    })
  },
  methods: {
    onSlide(payload) {
      const { index } = payload
      this.galleryIndex = index
      this.currentFile = this.photos[index]
    },
    removeCurrentFile() {
      this.$delete(this.photos, this.galleryIndex)
      this.$refs.gallery.instance.initSlides(true)
      this.$refs.gallery.instance.next()
      this.currentFile = null
      this.galleryIndex = null
    },
    toggleFullscreen() {
      const instance = this.$refs.gallery.instance;
      const container = document.querySelector('#blueimp-gallery')
      if (instance.getFullScreenElement()) {
        instance.exitFullScreen()
      } else {
        instance.requestFullScreen(container)
      }
    }
  }
}
</script>

<style lang='scss'>
.gallery-element { display: inline-block }
.blueimp-gallery .gallery-controls {
  position: absolute;
  top: 45px;
  left: 15px;
  color: #fff;
  display: none;
}
.blueimp-gallery-controls .gallery-controls {
  display: block;
}
.photo-stats {
  color: #999;
  display: block;
  .mdi {
    margin-left: 10px;
    margin-right: 3px;
  }
  .mdi:first-child {
    margin-left: 0;
  }
}
.blueimp-gallery > .slides > .slide > .video-content > video {
  display: block;
}
body {
  background-color: rgba(22,22,22,0.9);
}
.gallery-container {
  padding: 20px;
}


</style>
