<template lang="pug">
  #app(v-infinite-scroll="loadMore" infinite-scroll-distance="100" infinite-scroll-immediate-check infinite-scroll-disabled="disableScrollWatch")
    filter-bar()
    .gallery-container(v-if='photos.length > 0')
      v-gallery(:images="photos" :index="galleryControlIndex" @close="galleryControlIndex = null" ref='gallery' @onslide='onSlide')
        div(slot='controls'): .gallery-controls(v-if='currentFile')
          info-bar(:current-file='currentFile' @delete='removeCurrentFile' @fullscreen='toggleFullscreen')

      div(v-for='([year, months], i) in Object.entries(years).reverse()')
        section.hero.is-light
          .hero-body
            h3.title.is-4.is-marginless {{year}}
        template(v-for='([month, entries], i) in Object.entries(months)')
          section.hero.is-dark
            .hero-body
              h4.subtitle.is-5.is-marginless {{ entries[0].shotAt.format("dddd, DD. MMM") }}
          .day.container.is-fluid
            .gallery-element(v-for='(image, imageIndex) in entries' :key='image.id')
              photo-preview(v-if='image.data.type == "Photo"' :image='image' @click='openGallery(image)')
              video-preview(v-if='image.data.type == "Video"' :video='image' @click='openGallery(image)')
</template>

<script>
import VGallery from 'picapp/VGallery';
import 'blueimp-gallery/css/blueimp-gallery-video.css';
import PhotoPreview from 'picapp/components/photo-preview';
import VideoPreview from 'picapp/components/video-preview';
import InfoBar from 'picapp/components/info-bar';
import FilterBar from 'picapp/components/filter-bar';
import UploadedFile from 'picapp/uploaded-file';

import 'picapp/style.scss'

import { groupBy, mapValues, sortBy } from 'lodash';

var round = require('sugar/number/round');

export default {
  components: { VGallery, PhotoPreview, VideoPreview, InfoBar, FilterBar },
  data() {
    return {
      galleryIndex: -1,
      galleryControlIndex: null,
      currentFile: null,
      loadingItems: true,
      photos: [],
      pagination: {
        currentPage: 1,
        totalPages: 1,
        totalCount: 0
      },
    }
  },
  created() {
    this.getPhotos(1)
  },
  methods: {
    getPhotos(page) {
      this.loadingItems = true
      this.$http.get('/v3/api/photos', {
        params: {
          page: page
        }
      }).then(r => {
        if (page == 1) {
          this.photos = r.data.data.map(d => new UploadedFile(d, this.$moment))
        } else {
          this.photos = this.photos.concat(r.data.data.map(d => new UploadedFile(d, this.$moment)))
        }
        this.pagination.currentPage = page
        this.pagination.totalPages = r.data.meta.total_pages
        this.pagination.totalCount = r.data.meta.total_count
        this.loadingItems = false
        if (this.$refs.gallery) {
          this.galleryControlIndex = null
          // this.$refs.gallery.instance.unloadAllSlides()
          // this.$refs.gallery.instance.unloadElements()
          // this.$refs.gallery.destroy()
        }
      }).catch(error => {
        console.error(error)
      })
    },
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
    loadMore() {
      this.loadingItems = true
      if (this.pagination.totalPages > this.pagination.currentPage) {
        this.getPhotos(this.pagination.currentPage + 1)
      }
    },
    toggleFullscreen() {
      const instance = this.$refs.gallery.instance;
      const container = document.querySelector('#blueimp-gallery')
      if (instance.getFullScreenElement()) {
        instance.exitFullScreen()
      } else {
        instance.requestFullScreen(container)
      }
    },
    openGallery(file) {
      this.galleryControlIndex = this.photos.indexOf(file)
    }
  },
  computed: {
    disableScrollWatch() {
      return this.loadingItems || this.galleryControlIndex !== null;
    },
    years() {
      const yearGroups = groupBy(this.photos, (p) => p.shotAt.format('YYYY'))
      return mapValues(yearGroups, files => groupBy(files, (p) => p.shotAt.format("MM MMMM")))
    }
  }
}
</script>
