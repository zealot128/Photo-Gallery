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
    a.button.is-small.is-dark(@click='onDelete')
      i.mdi.mdi-delete
    br
    a(:href='currentFile.data.download_url' target='_blank') {{currentFile.data.file_size_formatted}}
</template>

<script>
  export default {
    props: ['currentFile'],
    computed: {
      exif() { return this.currentFile.data.exif }
    },
    methods: {
      onDelete() { this.$emit('delete', this.currentFile) }
    }
  }
</script>
