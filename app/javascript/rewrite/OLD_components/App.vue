<template lang="pug">
v-app
  v-main
    v-container(fluid)
      filter-bar(v-model='filter')

      media-loader(v-model='photos' :disable-auto-loading='galleryControlIndex != null' :filter='filter')
        .gallery-container(v-if='photos.length > 0' :class='{ "small-mode": isSmall }')
          div(v-for='([year, months], i) in Object.entries(years).reverse()')
            section.hero.is-light
              .hero-body
                h3.title.is-4.is-marginless {{year}}
            template(v-for='([month, days], i) in Object.entries(months)')
              section.hero.is-gray
                .hero-body
                  h4.subtitle.is-5.is-marginless
                    |{{ month.split(' ')[1] }}
              template(v-for='([day, entries], i) in Object.entries(days)')
                section.hero.is-dark
                  .hero-body
                    h4.subtitle.is-5.is-marginless
                      bulk-update(:files='entries' @input='updateFiles')
                      |{{ entries[0].shotAt.format("dddd, DD. MMM") }}
                .day.container.is-fluid
                  .gallery-element(v-for='(image, imageIndex) in entries' :key='image.id')
                    photo-preview(v-if='image.data.type == "Photo"' :image='image' @click='openGallery(image)' :is-small='isSmall')
                    video-preview(v-if='image.data.type == "Video"' :video='image' @click='openGallery(image)' :is-small='isSmall')
</template>

<script>

import Api from 'picapp/api';
import { groupBy, mapValues } from 'lodash';

import MediaLoader from './components/MediaLoader'

let keyCallback = null;

export default {
  components: { MediaLoader },
  props: {},
  data() {
    return {
      currentGalleryIndex: -1,
      isSmall: false,
      currentFile: null,
      // das steuert die gallery - wenn das gesetzt wird geht die Gallery auf
      galleryControlIndex: null,

      rotationInProgress: false,
      deleteModalIsOpen: null,
      editModalIsOpen: false,

      photos: [],
      filter: {
        fileTypes: ['photo', 'video'],
        query: null,
        from: null,
        to: null,
        favorite: null,
        peopleIds: [],
        includeWholeDay: false,
        cameraModels: [],
        aperture: []
      }
    }
  },
  methods: {
    updateCurrentFile(file) {
      this.photos[this.currentGalleryIndex] = this.currentFile
      this.currentFile = file
    },
    updateFiles(photos) {
      let index;
      photos.forEach((f) => {
        index = this.photos.findIndex(o => o.id === f.id)
        if (index) {
          this.photos[index] = f
        }
      })
    },
    onRotate({ direction, file }) {
      const addBust = string => string.replace(/\?.*/, "") + "?" + (new Date()).getTime()
      this.rotationInProgress = true
      const currentImage = this.$refs.gallery.instance.slides[this.currentGalleryIndex].children[0]
      let degrees = parseInt(currentImage.style.transform.match(/-?\d+/) || 0, 10)
      if (direction === 'right') {
        degrees += 90
      } else if (direction === 'left') {
        degrees -= 90
      }
      currentImage.style.transform = `rotate(${degrees}deg)`

      this.api.rotate(file.id, direction).then(() => {
        this.rotationInProgress = false
        currentImage.src = addBust(currentImage.src)
        this.currentFile.preview = addBust(this.currentFile.preview)
        this.currentFile.thumbnail = addBust(this.currentFile.thumbnail)

        this.photos = this.photos.map(ph => {
          if (ph.id === file.id) {
            return {
              ...ph,
              rotateDegrees: degrees,
            }
          } else {
            return ph
          }
        })
      })
    },
    onSlide(payload) {
      const { index } = payload
      this.currentGalleryIndex = index
      this.currentFile = this.photos[index]
    },
    removeCurrentFile() {
      this.api.deletePhoto(this.currentFile.id).then((_) => {
        this.deleteModalIsOpen = false
        this.$delete(this.photos, this.currentGalleryIndex)
        this.$refs.gallery.deleteCurrentPhoto()
        this.currentFile = null
        this.currentGalleryIndex = null
        this.closeDeleteModal()
      })
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
      keyCallback = this.keyup.bind(this)
      window.addEventListener('keyup', keyCallback, true)
      this.galleryControlIndex = this.photos.indexOf(file)
    },
    closeGallery() {
      window.removeEventListener('keyup', keyCallback, true)
      this.galleryControlIndex = null
    },
    openDeleteModal() {
      if (this.currentFile.isLiked()) {
        return
      }
      this.deleteModalIsOpen = true
      this.$refs.gallery.pauseEventListeners()
    },
    closeDeleteModal() {
      this.deleteModalIsOpen = null
      this.$refs.gallery.resumeEventListeners()
    },
    openEditModal() {
      this.editModalIsOpen = true
    },
    keyup(event) {
      switch (event.which) {
        case 68: // backspace
        case 46: // d
          if (!this.editModalIsOpen) {
            this.openDeleteModal()
            event.preventDefault();
          }
          break;
        case 69: // e
          if (!this.editModalIsOpen) {
            // edit
            this.openEditModal()
            event.preventDefault()
          }
          break;
        case 13: // Enter
          if (this.deleteModalIsOpen) {
            this.removeCurrentFile.bind(this)()
            event.preventDefault()
            event.stopPropagation()
          }
          break;
        case 27: // Esc
          if (this.deleteModalIsOpen) {
            this.closeDeleteModal()
            event.preventDefault()
            event.stopPropagation()
          }
          if (this.editModalIsOpen) {
            this.editModalIsOpen = false
            event.preventDefault()
            event.stopPropagation()
          }
      }
    }
  },
  computed: {
    api() { return new Api() },
    years() {
      const yearGroups = groupBy(this.photos, p => p.shotAt.format('YYYY'))
      return mapValues(yearGroups, (files) => {
        const months = groupBy(files, p => p.shotAt.format("MM MMMM"))
        return mapValues(months, monthFiles => groupBy(monthFiles, p => p.shotAt.format("DD DDDD")))
      })
    }
  },
  created() {
    this.$vuetify.theme.dark = true
  },
}
</script>

<style scoped></style>
