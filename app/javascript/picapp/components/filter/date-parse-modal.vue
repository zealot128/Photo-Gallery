<template lang="pug">
  div
    button.button(@click='modalOpen = true')
      i.mdi.mdi-calendar-check.mdi-fw
      |
      |Zeitraum einschränken
    .field.is-grouped.is-grouped-multiline(style='margin-top: 5px')
      .control: span.tags.has-addons(v-if='value.from')
        span.tag.is-dark von
        span.tag.is-primary {{value.from | moment("LL") }}
        a.tag.is-delete(@click='deleteTag("from")')

      .control: span.tags.has-addons(v-if='value.to')
        span.tag.is-dark bis
        span.tag.is-primary {{value.to | moment("LL") }}
        a.tag.is-delete(@click='deleteTag("to")')

    b-modal(:active.sync="modalOpen")
      .card
        .card-content
          p Datum einschränken
          b-field
            b-input(v-model="dateInput" @keyup.native='calculateRange' @change.native='calculateRange' autofocus)
            p.control
              button.button(@click='close') OK
          div(v-if='from')
            dl
              dt Von:
              dd {{from | moment("LL") }}
              dt Bis:
              dd {{to | moment("LL") }}

</template>

<script>
import dateParse from 'picapp/util/date-parser'

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
      this.value.from = this.from
      this.value.to = this.to
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
        [this.from, this.to] = answer
      }
    }
  }
}
</script>
