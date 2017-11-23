<template lang="pug">
  .image-preview(:style="style" @click='onClick')
    pic-like-button(:file='image' v-show='!isSmall')
</template>

<script>
import PicLikeButton from 'picapp/components/show/like-button';
export default {
  components: { PicLikeButton },
  props: ['image', 'index', 'isSmall'],
  computed: {
    width() {
      return this.isSmall ? 50 : 300
    },
    height() {
      return Math.round(this.width * 2 / 3);
    },
    style() {
      return {
        backgroundImage: `url(${this.image.preview})`,
        width: `${this.width}px`,
        height: `${this.height}px`
      }
    }
  },
  methods: {
    onClick() { this.$emit('click') }
  }
}
</script>

<style lang='scss' scoped>
.image-preview {
  background-color: rgba(22,22,22,0.9);
  transition: all .2s ease-in-out;
  position: relative;
  display: inline-block;
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
  cursor: pointer;
  &:hover {
    transform: scale(1.10);
    z-index: 1;
    box-shadow: 0 0 8px #333;
    background-size: contain;
    background-color: rgba(22,22,22,0.9);
  }
}
</style>
