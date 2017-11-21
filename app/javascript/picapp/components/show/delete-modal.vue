<template lang="pug">
  b-modal(:active="active")
    .card
      .card-content
        p Dieses Element wirklich löschen?
      .card-footer
        a.card-footer-item.is-danger(@click='yes')
          |Ja
        a.card-footer-item(@click='no')
          |Nein
</template>

<script>
export default {
  props: ['active'],
  methods: {
    yes() { this.$emit('yes') },
    no() { this.$emit('no') }
  }
}
</script>
