<template lang="pug">
  b-modal(:active="value" :on-cancel='close')
    .card(v-if='value && currentFile')
      .card-content
        p: strong Tags
        .columns
          .column
            button.button.is-small(v-for='tag in tags' :class='{ "is-primary" : isTagged(tag)}' @click='toggleTag(tag)')
              | {{tag.name}} ({{tag.taggings_count}})
          .column
            b-field
              b-input(v-model="newTag" placeholder='Neuen Tag anlegen')

        p: strong Shares
        .columns
          .column
            button.button.is-small(v-for='share in shares' :class='{ "is-primary" : isShared(share)}' @click='toggleShare(share)')
              | {{share.name}}
          .column
            b-field
              b-input(v-model="newShare" placeholder='Neues Share anlegen')

      .card-footer
        a.card-footer-item.is-danger(@click='save')
          |Speichern
</template>

<script>
import Api from 'picapp/api';
import UploadedFile from 'picapp/uploaded-file';

export default {
  props: ['value', 'currentFile'],
  data() {
    return {
      shares: [],
      tags: [],
      newTag: null,
      newShare: null,
      fileTags: [],
      fileShares: [],
    }
  },
  watch: {
    currentFile(newVal, _oldVal) {
      this.fileTags = newVal.data.tag_ids
      this.fileShares = newVal.data.share_ids
    }
  },
  methods: {
    close() { this.$emit('input', false) },
    save() {
      const hasNewTag = this.newTag && this.newTag !== ""
      const filteredTags = this.tags.filter(tag => this.isTagged(tag)).map(tag => tag.name)
      if (hasNewTag) {
        filteredTags.push(this.newTag)
      }
      this.buttonText = "...saving"
      this.api.updateFile(this.currentFile.data.id, {
        tag_list: filteredTags,
        share_ids: this.fileShares || [],
        new_share: this.newShare
      }).then((r) => {
        const file = new UploadedFile(r.data.photo, this.$moment)
        this.$emit('update', file)
        this.refreshItems()
        this.close()
      })
    },
    isTagged(tag) {
      return this.fileTags.includes(tag.id)
    },
    toggleTag(tag) {
      if (this.isTagged(tag)) {
        const index = this.fileTags.indexOf(tag.id)
        this.$delete(this.fileTags, index)
      } else {
        this.fileTags = [...this.fileTags, tag.id]
      }
    },
    isShared(tag) {
      return this.fileShares.includes(tag.id)
    },
    toggleShare(tag) {
      if (this.isShared(tag)) {
        const index = this.fileShares.indexOf(tag.id)
        this.$delete(this.fileShares, index)
      } else {
        this.fileShares = [...this.fileShares, tag.id]
      }
    },
    refreshItems() {
      this.api.getShares().then((r) => {
        this.shares = r.data
      })
      this.api.getTags().then((r) => {
        this.tags = r.data
      })
    }
  },
  mounted() {
    this.refreshItems()
  },
  computed: {
    api() { return new Api() },
  }
}
</script>

