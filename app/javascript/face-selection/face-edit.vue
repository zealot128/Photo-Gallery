<template lang='pug'>
div.face-selection
  br
  br

  .columns
    .column: .box.clearfix
      h3(v-if='!face.person_name')
        |Person zuweisen

      .columns
        .column
          img(:src='face.preview')
        .column
          div(v-if='matchedPeople.length > 0')
            p
              | Ist das vielleicht..?
            a.button.is-small(v-for='person in matchedPeople' @click.prevent='setPerson(person)')
              |{{person.name}} ({{person.count}})

      .is-pulled-right.buttons.has-addons
        button.button.is-danger.is-small(@click='deleteFace()' type='submit') Gesicht löschen
        button.button.is-small(@click='nextFace()' type='submit') Weiter
      b-field
        b-autocomplete(v-model='person_name' :data="filteredDataArray" placeholder="Name" ref='autocomplete')
        .control
          button.button.is-primary(@click='save()' type='submit')
            |Anlegen/Zuweisen

    .column: .box
      strong Ähnliche Gesichter abfragen
      b-field(grouped)
        b-field(label="Ähnlichkeit")
          b-input(class="form-control" v-model="apiParams.similarity" placeholder='' type='number')
        b-field(label="Max. Photos")
          b-input(class="form-control" v-model="apiParams.max" placeholder='' type='number')
        b-field(label="Konfidenz")
          b-input(class="form-control" v-model="apiParams.confidence" placeholder='' type='number')
        b-field(label="")
          button(type='submit' class='button' @click.prevent='refreshSimilarities()')
            |Refresh

      p: strong
        |Alle ausgewählten Gesichter ebenfalls zu einer Person hinzufügen.

      p(v-if='allSimilarCount > 0')
        | {{allSimilarCount}} ähnliche Gesichter gefunden.

      .buttons(v-if='similarUnassigned.length > 0')
        a.button.is-small(@click.prevent='selectAll()')
          i.mdi.mdi-checkbox-multiple-marked-outline.mdi-fw
        a.button.is-small(@click.prevent='unselectAll()')
          i.mdi.mdi-checkbox-multiple-blank-outline.mdi-fw

      .buttons
        .button.face-toggle(v-for='other_face in similarUnassigned' :class='{ "is-primary" : selected(other_face)}')
          figure.image
            img(:src='other_face.preview' @click='toggleSelect(other_face)')
          br
          small(title='Similarity with face - Confidence that it is a face')
            | {{round(other_face.similarity)}}% &ndash; {{round(other_face.confidence)}}
          a(:href='"/v2/faces/" + other_face.id')
            i.mdi.mdi-open-in-new.mdi-fw
      div(v-if='similarUnassigned.length == 0')
        i Keine ähnlichen gefunden.

      br
      br
      br
</template>

<script>
import Api from 'picapp/api'

export default {
  props: ['face'],
  data() {
    return {
      // autocompletion
      allPeople: [],

      // Nutzer auswahl
      person_name: "",
      selectedFaces: [],

      // api result:
      allSimilarCount: 0,
      matchedPeople: [],
      similarUnassigned: [],
      api: null,
      apiParams: {
        similarity: 80,
        confidence: 0,
        max: 500,
      },
    }
  },
  watch: {
    face(_newVal) {
      this.init()
    }
  },
  mounted() {
    this.api = new Api()
    this.init()
  },
  methods: {
    init() {
      this.allSimilarCount = 0;
      this.matchedPeople = []
      this.similarUnassigned = []
      this.selectedFaces = [this.face.id];
      this.person_name = this.face.person_name || "";
      this.refreshSimilarities();
      this.api.getPeople().then((p) => { this.allPeople = p })
    },
    deleteFace() {
      this.api.deleteFaces([this.face.id]).then(() => {
        this.$emit('delete', this.face.id)
      })
    },
    nextFace() {
      this.$emit('next')
    },
    refreshSimilarities() {
      this.api.getSimilarImages(this.face, this.apiParams.max, this.apiParams.similarity).then((allSimilar) => {
        this.allSimilarCount = allSimilar.length
        this.similarUnassigned = []
        this.selectedFaces = [this.face.id]
        const people = {}
        allSimilar.forEach((el) => {
          if (el.confidence >= this.apiParams.confidence) {
            if (!(el.person_id)) {
              this.similarUnassigned.push(el)
            } else {
              people[el.person_name] = people[el.person_name] || 0
              people[el.person_name] += 1
            }
          }
        })

        this.matchedPeople = []
        Object.entries(people).forEach((entry) => {
          const [k, v] = entry
          this.matchedPeople.push({ name: k, count: v })
        })
      })
    },
    setPerson(person) {
      this.person_name = person.name
      this.$nextTick(() => this.$refs.autocomplete.isActive = false)
    },
    round(value) { return Math.round(value * 10) / 10 },
    selectAll() {
      const ids = this.similarUnassigned.map(i => i.id)
      this.selectedFaces = ids
      this.selectedFaces.push(this.face.id)
    },
    unselectAll() {
      this.selectedFaces = [this.face.id]
    },
    save() {
      this.api.setFaces(this.person_name, this.selectedFaces, []).then((_) => {
        this.face.person_name = this.person_name
        this.selectedFaces.forEach((id) => {
          this.$emit('delete', id)
        })
        this.refreshSimilarities()
      })
    },
    selected(face) { return this.selectedFaces.includes(face.id) },
    toggleSelect(face) {
      this.toggleObject(face, this.selectedFaces)
    },
    toggleObject(object, array) {
      if (array.indexOf(object.id) !== -1) {
        const index = array.indexOf(object.id)
        this.$delete(array, index)
      } else {
        array.push(object.id)
      }
    }
  },
  computed: {
    filteredDataArray() {
      return this.allPeople.map(p => p.name).filter(option => option
        .toString()
        .toLowerCase()
        .indexOf(this.person_name.toLowerCase()) >= 0)
    }
  }
}
</script>

<style>
  .face-toggle {
    white-space: normal;
    height: auto;
    flex-direction: column;
  }
</style>
