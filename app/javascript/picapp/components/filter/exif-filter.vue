<template lang="pug">
  div
    button.button(@click='open')
      i.mdi.mdi-camera.mdi-fw
      |
      |EXIF Eigenschaften

    b-modal(:active.sync="modalOpen" :on-cancel='close')
      .card
        .card-content
          p Kamera-Model
          button.button.is-small(v-for='tag in cameraModels' :class='{ "is-primary" : isSelected(tag.name, "selectedCameraModals")}' @click='toggleSelect(tag.name, "selectedCameraModals")')
            | {{tag.name}} ({{tag.count}})
        .card-content
          p Blenden
          button.button.is-small(v-for='aperture in apertures' :class='{ "is-primary" : isSelected(aperture.name, "selectedApertures")}' @click='toggleSelect(aperture.name, "selectedApertures")')
            | {{aperture.name}} ({{aperture.count}})
        .card-footer
          a.card-footer-item(@click='close')
            |Anwenden

</template>

<script>
import Api from 'picapp/api';

export default {
  props: ['value'],
  data() {
    return {
      modalOpen: false,
      cameraModels: [],
      apertures: [],
      selectedCameraModals: [],
      selectedApertures: [],
    }
  },
  methods: {
    open() {
      this.modalOpen = true
      this.api.getExifData().then((response) => {
        this.cameraModels = response.data.camera_models;
        this.apertures = response.data.aperture;
      })
    },
    close() {
      this.modalOpen = false
      const newValue = { ...this.value, cameraModels: this.selectedCameraModals, apertures: this.selectedApertures }
      this.$emit('input', newValue)
    },
    isSelected(tag, collection) {
      return this[collection].includes(tag)
    },
    toggleSelect(tag, collection) {
      if (this.isSelected(tag, collection)) {
        const index = this[collection].indexOf(tag)
        this.$delete(this[collection], index)
      } else {
        this[collection] = [...this[collection], tag]
      }
    },
  },
  computed: {
    api() { return new Api() },
  }
}
</script>

