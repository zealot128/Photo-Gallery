<template lang="pug">
  .search-container
    .field.has-addons
      .control: pic-upload-bar
      .control: pic-nav-icon(current-page='pics')
      .control: b-dropdown(position="is-bottom-left" v-model='dropdownOpen')
        a.button.is-primary.is-large(slot="trigger" :class='{"is-outlined": !dropdownOpen}')
          i.mdi.mdi-magnify
          i.mdi.mdi-menu-down
        b-dropdown-item(custom paddingless)
          .modal-card(style='min-width: 300px; max-width: 600px')
            section.modal-card-body
              |Filter
              .columns.block
                .column
                  b-checkbox(v-model="valueProxy.fileTypes" native-value="photo") Photos
                  b-checkbox(v-model="valueProxy.fileTypes" native-value="video") Videos
                .column
                  b-checkbox(v-model="valueProxy.favorite") Favoriten
              .columns.block
                .column
                  pic-date-parse-modal(v-model='valueProxy')
                .column
                  pic-exif-filter(v-model='valueProxy')
              .block
                b-field(label='Suchbegriff/Schlagwort')
                  b-input(v-model='valueProxy.query' @keyup.native.enter='apply')
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
              p Person hinzufügen (nur Photos)
              .block.face-select
                b-checkbox(v-for='person in people' v-model='valueProxy.peopleIds'
                  :native-value='person.id' :key='person.id' :name='"person" +person.id')
                    img(:src='person.preview')
                    |
                    small.is-text-overflow {{person.name}}
              .block
                b-checkbox(v-model="valueProxy.includeWholeDay") Dateien des gleichen Tages wie Gefundene mit anzeigen
            .card-footer
              a.card-footer-item(@click='openAddPersonModal = false')
                |Schließen
      .control: slot


</template>

<script>
import Api from 'picapp/api';
import PicDateParseModal from 'picapp/components/filter/date-parse-modal';
import PicExifFilter from 'picapp/components/filter/exif-filter';
import PicNavIcon from 'picapp/components/nav-icon';
import PicUploadBar from 'picapp/components/upload-bar';
const api = new Api()

export default {
  components: {
    PicDateParseModal, PicNavIcon, PicUploadBar, PicExifFilter
  },
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
  computed: {
    valueProxy: {
      get() { return this.value },
      set(val) {
        this.$emit('input', val)
      }
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
  .b-checkbox {
    width: 80px;
  }
  .control-label {
    overflow: hidden;
    display: flex;
    flex-direction: column;
    img {
      height: 40px;
      width: 40px;
    }
    small {
      text-align: center;
    }
  }
}

</style>

