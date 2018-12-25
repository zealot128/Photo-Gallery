<template lang="pug">
  div.date-parse-modal
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
          .columns
            .column
              b-field
                b-datepicker(v-model='from' icon="calendar-today" placeholder='Von' :max-date='maxDate')
            .column
              b-field
                b-datepicker(v-model='to' icon="calendar-today" placeholder='Bis' :max-date='maxDate')
          p.control
            button.button(@click='close') OK

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
  computed: {
    maxDate() {
      return new Date()
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

<style lang='scss'>
.date-parse-modal {
  .modal, .animation-content, .card {
    overflow: visible !important;
  }
}
</style>
