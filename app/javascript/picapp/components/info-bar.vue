<template lang="pug">
  div
    small(v-if='currentFile.data.type == "Photo"')
      |{{exif.model}}
      span.photo-stats(v-if='exif.focal_length')
        i.mdi.mdi-camera
        |{{exif.focal_length}}
        i.mdi.mdi-camera-iris
        |{{exif.aperture}}
        i.mdi.mdi-timer
        |{{exif.exposure_time}}
      br
      |{{currentFile.data.location}}
    .buttons.has-addons(v-if='currentUser')
      b-tooltip(label="Löschen")
        a.button.is-dark(@click='onDelete')
          i.mdi.mdi-delete
      b-tooltip(label="Bearbeiten")
        a.button.is-dark(@click='onEdit')
          i.mdi.mdi-tag
      b-tooltip(label="Nach links kippen (90 Grad)")
        a.button.is-dark(@click='onRotateLeft')
          i.mdi.mdi-rotate-left
      b-tooltip(label="Nach rechts kippen (90 Grad)")
        a.button.is-dark(@click='onRotateRight')
          i.mdi.mdi-rotate-right
    br
    .buttons.has-addons
      b-tooltip(label="Full-Screen")
        a.button.is-inverted.is-outlined.is-dark(@click='onFullscreen')
          i.mdi.mdi-fullscreen
      b-tooltip(label="Download der Original-Datei")
        a.button.is-inverted.is-outlined.is-primary(:href='currentFile.data.download_url' target='_blank') {{currentFile.data.file_size_formatted}}
</template>

<script>
  export default {
    props: ['currentFile'],
    methods: {
      onDelete() { this.$emit('delete', this.currentFile) },
      onEdit() { this.$emit('edit', this.currentFile) },
      onRotateLeft() { this.$emit('rotate', { direction: 'left', file: this.currentFile }) },
      onRotateRight() { this.$emit('rotate', { direction: 'right', file: this.currentFile }) },
      onFullscreen() { this.$emit('fullscreen', this.currentFile) },
    },
    computed: {
      exif() { return this.currentFile.data.exif },
      currentUser() {
        return currentUser;
      }
    }
  }
</script>
