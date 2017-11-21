<template lang="pug">
  .video-preview(:style="{ backgroundImage: 'url(' + currentFrame + ')' }" @click='onClick' @mouseenter='onMouseEnter' @mouseleave='onMouseLeave')
    i.mdi.mdi-play-circle.play-icon
    span(v-if='!video.data.video_processed')
      |unprocessed
    .duration
      | {{duration}}
    img.preload(v-for='tb in video.data.thumbnails' :src='tb' v-if='mouseIsOver')
    pic-like-button(:file='video')
</template>

<script>
import PicLikeButton from 'picapp/components/show/like-button';
export default {
  components: { PicLikeButton },
  props: ['video', 'index'],
  data() {
    return {
      currentFrame: this.video.preview,
      mouseIsOver: false,
      currentFrameIndex: 0
    }
  },
  methods: {
    onClick() { this.$emit('click') },
    resetFrame() {
      this.currentFrame = this.video.preview
      this.currentFrameIndex = 0
    },
    onMouseEnter(e) {
      this.mouseIsOver = true
      this.frame()
    },
    onMouseLeave(e) {
      this.mouseIsOver = false
      this.resetFrame()
    },
    frame() {
      if (!this.mouseIsOver) {
        return
      }
      const next_image = this.video.data.thumbnails[this.currentFrameIndex]
      if(next_image) {
        this.currentFrame = next_image
        this.currentFrameIndex += 1
      } else {
        this.resetFrame()
      }
      setTimeout( () => this.frame(), 500 )
    }
  },
  computed: {
    duration() { return this.video.data.exif.durationHuman }
  }
}
</script>

<style lang='scss'>
.video-preview {
  transition: all .2s ease-in-out;
  display: inline-block;
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
  width: 300px;
  height: 200px;
  position: relative;
  text-align: center;
  cursor: pointer;
  &:hover {
    transform: scale(1.10);
    z-index: 1;
    box-shadow: 0 0 8px #333;
    background-size: contain;
    background-color: rgba(22,22,22,0.9);
    .duration {
      transition: color 0.3s ease;
      color: white;
      text-shadow: 0 0 2px #555;
    }
    .play-icon {
      color: white;
      transition: color 0.3s ease;
    }
  }
  .duration {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    color: #666;
    transition: color 0.3s ease;
  }
  .unprocessed {
    text-align: center;
    position: absolute;
    left: 0;
    right: 0;
    font-style: italic;
    color: #444;
  }
  .play-icon {
    position: absolute;
    left: 0;
    right: 0;
    top: 93px;
    bottom: 0;
    color: #666;
    font-size: 30px;
    width: auto;
    transition: color 0.3s ease;
  }
  .preload {
    opacity: 0;
    position: absolute;
    z-index: -1;
    width: 1px;
  }
}
</style>

