<template lang="pug">
  button.button.is-primary.is-large(@click='toggleIsSmall' :class='{"is-outlined": !value}')
    i.mdi.mdi-fw.mdi-map
</template>

<script>
export default {
  props: ['value'],
  methods: {
    toggleIsSmall() {
      if (!this.value) {
        const topMost = Array.from(document.querySelectorAll('.hero')).filter(el => el.offsetTop > window.scrollY)[0]
        this.$emit('input', true)
        setTimeout(() => {
          // const elementMovedBy = offsetBefore - topMost.offsetTop
          // const scrollMovedBy = scrollBefore - window.scrollY
          if (topMost.offsetTop < window.scrollY) {
            this.$SmoothScroll(topMost.offsetTop - 50)
          }
        }, 500)
      } else {
        this.$emit('input', false)
      }
    },
  }
}
</script>
