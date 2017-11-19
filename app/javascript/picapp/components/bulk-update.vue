<template lang="pug">
  div
    a.button.is-small.is-pulled-right.is-outlined.is-light(@click='openModal()')
      i.mdi.mdi-tag
    b-modal(:active.sync="modalOpen")
      .card
        .card-content
          p.subtitle Tags
          .columns
            .column: .buttons
              button.button.is-small(v-for='tag in tags' :class='{ "is-dark" : isTagged(tag, "selectedTags")}' @click='toggleTag(tag, "selectedTags")')
                | {{tag.name}} ({{tag.taggings_count}})
            .column
              b-field
                b-input(v-model="newTag" placeholder='Neuen Tag anlegen')
          p.subtitle Shares
          .columns
            .column: .buttons
              button.button.is-small(v-for='tag in shares' :class='{ "is-dark" : isTagged(tag, "selectedShares")}' @click='toggleTag(tag, "selectedShares")')
                | {{tag.name}}
            .column
              b-field
                b-input(v-model="newShare" placeholder='Neues Share anlegen')
          .buttons
            button.button(v-for='file in files' :key='file.id' :class='{ "is-dark" : isTagged(file, "selectedFiles")}' @click='toggleTag(file, "selectedFiles")')
              img(:src='file.preview' style='height: 28px')
        .card-footer
          a.card-footer-item.is-danger(@click='save')
            |Speichern
</template>

<script>
import Api from 'picapp/api';
import UploadedFile from 'picapp/uploaded-file';

import intersection from 'lodash/intersection'

/* eslint no-return-assign: 0 */

export default {
  props: ['files'],
  data() {
    return {
      modalOpen: false,
      shares: [],
      tags: [],
      selectedFiles: [],
      selectedTags: [],
      selectedShares: [],
      newShare: null,
      newTag: null,
    }
  },
  methods: {
    openModal() {
      Promise.all([
        this.api.getShares().then(r => this.shares = r.data),
        this.api.getTags().then(r => this.tags = r.data)
      ]).then(() => {
        this.selectedShares = intersection.apply(this, this.files.map(f => f.data.share_ids))
        this.selectedTags = intersection.apply(this, this.files.map(f => f.data.tag_ids))
      })
      this.selectedFiles = this.files.map(e => e.id)
      this.modalOpen = true
    },
    save() {
      const request = {
        tag_ids: this.selectedTags,
        new_tag: this.newTag,
        share_ids: this.selectedShares,
        new_share: this.newShare,
        file_ids: this.selectedFiles
      }
      this.api.bulkUpdate(request).then((r) => {
        this.modalOpen = false
        this.$emit('input', r.data.map(f => (new UploadedFile(f, this.$moment))))
      })
    },
    isTagged(tag, collection) {
      return this[collection].includes(tag.id)
    },
    toggleTag(tag, collection) {
      if (this.isTagged(tag, collection)) {
        const index = this[collection].indexOf(tag.id)
        this.$delete(this[collection], index)
      } else {
        this[collection] = [...this[collection], tag.id]
      }
    },
  },
  computed: {
    api() { return new Api() },
  }
}

</script>

<style>
  .modal .card .subtitle {
    color: #444 !important;
  }
  .hero.is-dark .subtitle a:not(.button), .hero.is-dark .subtitle strong {
    color: inherit !important;
  }
</style>
