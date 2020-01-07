<template lang="pug">
.card: .card-content
  .columns
    .column(v-for='(groupChecks, group) in checks')
      h3.title.is-3 {{group}}
      .notification(v-for='check in groupChecks' :class='cssClass(check)')
        span(v-html='check.title')
</template>

<script>
import Api from 'picapp/api';
export default {
  components: {},
  props: {},
  data() {
    return {
      checks: {},
    }
  },
  computed: {
    api() { return new Api() },
  },
  mounted() {
    this.fetch()
  },
  methods: {
    cssClass(check) {
      if (check.status === 'success') {
        return "is-success"
      } else if (check.status === 'warning') {
        return "is-warning"
      } else {
        return "is-danger"
      }
    },
    async fetch() {
      const data = await this.api.status()
      this.checks = data.checks
    }
  },
}
</script>

<style scoped>
.notification {
  margin: 0 0 1px 0 !important;
  padding: 5px 10px;
}
</style>
