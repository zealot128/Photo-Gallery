<template lang="pug">
  div
    button.button(@click='open')
      i.mdi.mdi-camera.mdi-f
      |
      |EXIF Eigenschaften

    b-modal(:active.sync="modalOpen" :on-cancel='close')
      .card
        .card-content
          p Kamera-Model
          button.button.is-small(v-for='tag in cameraModels' :class='{ "is-primary" : isSelected(tag.name, "selectedCameraModals")}' @click='toggleSelect(tag.name, "selectedCameraModals")')
            | {{tag.name}} ({{tag.count}})
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
      selectedCameraModals: []
    }
  },
  methods: {
    open() {
      this.modalOpen = true
      this.api.getExifData().then((response) => {
        this.cameraModels = response.data.camera_models;
      })
    },
    close() {
      this.modalOpen = false
      const newValue = { ...this.value, cameraModels: this.selectedCameraModals }
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

