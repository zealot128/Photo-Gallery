<template lang="pug">
  div
    .is-hidden-mobile
      small(v-if='currentFile.data.type == "Photo"')
        |{{exif.model}}
        span.photo-stats(v-if='exif.focal_length')
          i.mdi.mdi-camera
          |{{exif.focal_length}}
          i.mdi.mdi-camera-iris
          |{{exif.aperture}}
          i.mdi.mdi-timer
          |{{exif.exposure_time}}
          |
          small(style='margin-left: 5px') ISO
          |
          |{{exif.iso}}
        br
        |{{currentFile.data.location}}
      small(v-if='currentFile.data.type == "Video"')
        br
    .buttons.has-addons.is-hidden-mobile(v-if='currentUser')
      button.button.is-dark(@click='onDelete' v-if='!liked')
        b-tooltip(label="Löschen")
          i.mdi.mdi-delete
      button.button.is-dark(@click='onEdit')
        b-tooltip(label="Bearbeiten")
          i.mdi.mdi-tag
      button.button.is-dark(@click='onRotateLeft')
        b-tooltip(label="Nach links kippen (90 Grad)")
          i.mdi.mdi-rotate-left
      button.button.is-dark(@click='onRotateRight')
        b-tooltip(label="Nach rechts kippen (90 Grad)")
          i.mdi.mdi-rotate-right
    br
    .buttons.has-addons
      button.button.is-inverted.is-outlined(@click='toggleFaceMode' :class='{"is-dark": !faceMode }' v-if='hasFaces')
        b-tooltip(label="Gesichter anzeigen")
          i.mdi.mdi-face
          small {{faceCount}}
      button.button.is-inverted.is-outlined.is-dark(@click='onFullscreen')
        b-tooltip(label="Full-Screen")
          i.mdi.mdi-fullscreen
      a.button.is-inverted.is-outlined.is-primary(:href='currentFile.data.download_url' target='_blank')
        b-tooltip(label="Download der Original-Datei")
          | {{currentFile.data.file_size_formatted}}
    div.face-wrapper(v-show='faceMode')
      .face-box(:style='{ width: imageWidth + "px", height: imageHeight + "px"}')
        pic-bounding-box(v-for='face in currentFile.data.faces' :face='face' :width='imageWidth' :height='imageHeight' key='face.id')
</template>

<script>
import PicBoundingBox from 'picapp/components/show/bounding-box'
/* globals currentUser */
export default {
  components: { PicBoundingBox },
  props: ['currentFile', 'gallery'],
  data() {
    return {
      faceMode: false,
      imageWidth: 640,
      imageHeight: 480
    }
  },
  methods: {
    onDelete() { this.$emit('delete', this.currentFile) },
    onEdit() { this.$emit('edit', this.currentFile) },
    onRotateLeft() { this.$emit('rotate', { direction: 'left', file: this.currentFile }) },
    onRotateRight() { this.$emit('rotate', { direction: 'right', file: this.currentFile }) },
    onFullscreen() { this.$emit('fullscreen', this.currentFile) },
    toggleFaceMode() {
      if (!this.faceMode) {
        const slide = this.gallery.instance.slides[this.gallery.instance.index].children[0]
        this.imageWidth = slide.width
        this.imageHeight = slide.height
      }
      this.faceMode = !this.faceMode
    }
  },
  computed: {
    exif() { return this.currentFile.exif },
    currentUser() {
      return currentUser;
    },
    liked() { return this.currentFile.isLiked() },
    faceCount() { return this.currentFile.data.faces && this.currentFile.data.faces.length },
    hasFaces() {
      return this.faceCount > 0
    }
  }
}
</script>

<style>
.face-box {
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  margin: auto;
  position: fixed;
}
.bb-image {
  display: inline-block;
  position: relative;
}
.bb-face {
  border: 2px solid #ddd;
  position: absolute;
  color: white;
  text-align: center;
}
img.slide-content {
  transition: all 0.3s ease-in-out;
}
@media screen and (max-width: 768px) {
  .gallery-container .blueimp-gallery .gallery-controls {
    position: absolute;
    top: auto;
    left: auto;
    bottom: 5px;
    right: 5px;
  }

}
</style>
