<template lang="pug">
  #app
    //p {{message}}
    //i(class="mdi mdi-bell")
    div(v-if='photos.length > 0')
      v-gallery(:images="photos" :index="galleryIndex" @close="galleryIndex = null" ref='gallery' @onslide='onSlide')
        div(slot='controls'): .gallery-controls(v-if='currentFile')
          small(v-if='currentFile.data.type == "Photo"')
            |{{currentFile.data.exif.model}}
            span.photo-stats(v-if='currentFile.data.exif.focal_length')
              i.mdi.mdi-camera
              |{{currentFile.data.exif.focal_length}}
              i.mdi.mdi-camera-iris
              |{{currentFile.data.exif.aperture}}
              i.mdi.mdi-timer
              |{{currentFile.data.exif.exposure_time}}
            br
            |{{currentFile.data.location}}
          a(:href='currentFile.data.download_url' target='_blank') {{currentFile.data.file_size_formatted}}

      div.image-preview(
        v-for="(image, imageIndex) in photos"
        :key="imageIndex"
        @click="galleryIndex = imageIndex"
        :style="{ backgroundImage: 'url(' + image.preview + ')', width: '300px', height: '200px' }"
      )
</template>

<script>
import VGallery from 'picapp/VGallery';

class Photo {
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
  components: { VGallery },
  data() {
    return {
      galleryIndex: 0,
      currentFile: null,
      photos: [],
      pagination: {
        currentPage: 1,
        totalPages: 1,
        totalCount: 0
      },
      message: "Hello Vue!"
    }
  },
  created() {
    this.$http.get('/v3/api/photos', {
    }).then(r => {
      this.photos = r.data.data.map(d => new Photo(d))
      this.pagination.currentPage = 1
      this.pagination.totalPages = r.data.meta.total_pages
      this.pagination.totalCount = r.data.meta.total_count
      console.log(this.photos)
    }).catch(error => {
      console.error(error)
    })
  },
  methods: {
    onSlide(payload) {
      const { index } = payload
      this.currentFile = this.photos[index]
    }
  }
}
</script>

<style lang='scss'>
.image-preview {
  display: inline-block;
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
}
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
</style>
