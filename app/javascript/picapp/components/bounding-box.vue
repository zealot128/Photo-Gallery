<template lang="pug">
  a.bb-face(:style='styleObject' :href='faceUrl' target='_blank' :title='name')
    | {{name}}
</template>

<script>

/* eslint prefer-template: 0 */

export default {
  props: ['face', 'width', 'height'],
  computed: {
    name() { return this.face.person_name },
    faceUrl() { return `/v2/faces/${this.face.id}` },
    styleObject() {
      const bb = this.face.bounding_box
      const w = Math.round(bb.width * this.width)
      const h = Math.round(bb.height * this.height)
      const t = Math.round(bb.top * this.height)
      const l = Math.round(bb.left * this.width)
      return {
        left: l + "px",
        top: t + "px",
        width: w + "px",
        height: h + "px"
      }
    }
  }
}
</script>
