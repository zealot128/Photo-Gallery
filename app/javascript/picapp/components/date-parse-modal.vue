<template lang="pug">
  div
    button.button(@click='modalOpen = true')
      i.mdi.mdi-calendar-check.mdi-fw
      |
      |Zeitraum einschränken
    div(style='margin-top: 5px')
      span.tags.has-addons(v-if='value.from')
        span.tag.is-dark von
        span.tag.is-info {{value.from | moment("LL") }}
        a.tag.is-delete(@click='deleteTag("from")')

      |
      span.tags.has-addons(v-if='value.to')
        span.tag.is-dark bis
        span.tag.is-info {{value.to | moment("LL") }}
        a.tag.is-delete(@click='deleteTag("to")')

    b-modal(:active.sync="modalOpen")
      .card
        .card-content
          p Datum einschränken
          b-field
            b-input(v-model="dateInput" @keyup.native='calculateRange' @change.native='calculateRange' autofocus)
            p.control
              button.button(@click='close') OK


          div(v-if='value.from')
            dl
              dt Von:
              dd {{value.from | moment("LL") }}
              dt Bis:
              dd {{value.to | moment("LL") }}

</template>

<script>
import dateParse from 'picapp/date-parser'

export default {
  props: ['value'],
  data() {
    return {
      modalOpen: false,
      dateInput: "",
      from: null,
      to: null
    }
  },
  methods: {
    deleteTag(what) {
      this.value[what] = null
      this.$emit('input', this.value)
    },
    close() {
      this.modalOpen = false
      if (this.value.from) {
        this.value.from = this.$moment(this.value.from).utcOffset(0, true).format("YYYY-MM-DD")
      }
      if (this.value.to) {
        this.value.to = this.$moment(this.value.to).utcOffset(0, true).format("YYYY-MM-DD")
      }
      this.$emit('input', this.value)
    },
    calculateRange(event) {
      if (event.key === 'Enter') {
        this.close()
        return
      }
      const answer = dateParse(this.dateInput)
      if (answer) {
        [this.value.from, this.value.to] = answer
      }
    }
  }
}
</script>
