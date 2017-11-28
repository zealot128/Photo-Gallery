<template lang='pug'>
div
  .search-container
    .field.has-addons
      .control: pic-nav-icon(current-page='faces')
  section.hero.is-dark
    .hero-body
      h3.title.is-4 Gesichter zuweisen
    .container.is-fluid
      a(@click='selectedFace = face' v-for='face in faces' style='margin-right: 25px; margin-top: 10px; margin-bottom: 10px; display: inline-block')
        img(:src='face.preview')

  section.hero.is-light(v-if='selectedFace')
    .container.is-fluid
      face-edit(:face='selectedFace' @next='nextFace' @delete='deleteFace')

</template>

<script>
import Api from 'picapp/api'
import FaceEdit from 'face-selection/face-edit'
import PicNavIcon from 'picapp/components/nav-icon';

export default {
  components: { FaceEdit, PicNavIcon },
  data() {
    return {
      selectedFace: null,
      faces: []
    }
  },
  methods: {
    nextFace() {
      const currentIndex = this.faces.indexOf(this.selectedFace)
      this.selectedFace = this.faces[currentIndex + 1]
    },
    deleteFace(faceId) {
      const currentIndex = this.faces.findIndex(f => f.id === faceId)
      this.$delete(this.faces, currentIndex)
      if (this.selectedFace.id === faceId) {
        this.nextFace()
      }
    }
  },
  mounted() {
    this.api.getUnassignedFaces().then((r) => {
      this.faces = r
    })
  },
  computed: {
    api() { return new Api() }
  }
}
</script>

<style lang='scss'>
.search-container {
  position: fixed;
  right: 15px;
  top: 15px;
  z-index: 2;
}
</style>
