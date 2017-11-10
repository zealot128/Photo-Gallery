<template lang="pug">
  .like-button
    a(v-if='liked' href='#' @click.prevent.stop='unlike()')
      i.mdi.mdi-star(title='Like')
    a(v-if='!liked' href='#' @click.prevent.stop='like()')
      i.mdi.mdi-star-outline(title='Unlike')
</template>

<script>
  import Api from 'picapp/api';
  const api = new Api
  /* globals currentUser */
  export default {
    props: ['file'],
    computed: {
      liked() { return this.likedBy.indexOf(currentUser) !== -1 },
      likedBy() { return this.file.data.liked_by },
    },
    methods: {
      like() {
        api.like(this.file.data.id)
        if (!this.liked) {
          this.file.data.liked_by = [...this.file.data.liked_by, currentUser]
        }
      },
      unlike() {
        api.unlike(this.file.data.id)
        const index = this.likedBy.indexOf(currentUser)
        if(index != -1) {
          this.$delete(this.likedBy, index)
        }
      }
    }
  }
</script>

<style lang='scss'>
  .like-button {
    position: absolute;
    right: 0;
    top: 0;
    font-size: 1.5rem;
    a {
      text-shadow: 0 0 2px #000;
      color: #ddd;
    }
  }
</style>
