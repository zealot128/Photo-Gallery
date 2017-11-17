<template lang="pug">
  .search-container
    b-dropdown(position="is-bottom-left" v-model='dropdownOpen')
      a.button.is-primary.is-large.is-outlined(slot="trigger")
        i.mdi.mdi-magnify
        i.mdi.mdi-menu-down
      b-dropdown-item(custom paddingless)
        .modal-card(style='min-width: 300px; max-width: 600px')
          section.modal-card-body
            |Filter
            .block
              b-checkbox(v-model="value.fileTypes" native-value="photo") Photos
              b-checkbox(v-model="value.fileTypes" native-value="video") Videos
            .block
              b-checkbox(v-model="value.favorite") Favoriten
            .block
              date-parse-modal(v-model='value')
            .block
              div: span(v-for='personId in value.peopleIds')
                img(:src='findPerson(personId).preview' style='height: 30px')
              button.button(@click='openAddPersonModal = true')
                i.mdi.mdi-face-profile.mdi-fw
                |
                |Person suchen
            button.button.is-primary(@click='apply') Anwenden

      b-modal(:active.sync="openAddPersonModal" v-if='people.length > 0')
        .card
          .card-content
            p Person hinzufügen
            .block.face-select
              b-checkbox(v-for='person in people' v-model='value.peopleIds'
                :native-value='person.id' :key='person.id' :name='"person" +person.id')
                  img(:src='person.preview')
                  |
                  small {{person.name}}
            .block
              b-checkbox(v-model="value.includeWholeDay") Dateien des gleichen Tages wie Gefundene mit anzeigen
          .card-footer
            a.card-footer-item(@click='openAddPersonModal = false')
              |Schließen


</template>

<script>
import Api from 'picapp/api';
import DateParseModal from 'picapp/components/date-parse-modal';
const api = new Api()

export default {
  components: { DateParseModal },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      openAddPersonModal: false,
      dropdownOpen: false,
      people: []
    }
  },
  created() {
    api.getPeople().then((p) => {
      this.people = p
    })
  },
  methods: {
    apply() {
      this.dropdownOpen = true
      const newHash = { ...this.value }
      this.$emit('input', newHash)
    },
    findPerson(id) {
      return this.people.find(p => p.id === parseInt(id, 10))
    }
  }
}
</script>

<style lang='scss'>
.search-container {
  position: fixed;
  right: 15px;
  top: 15px;
  z-index: 2;
}
.face-select {
  .control-label {
    display: flex;
    margin-right: 15px;
    img {
      height: 40px;
      margin-right: 10px;
    }
    small {
      align-self: center;
    }
  }
}

</style>

