<template lang="pug">
  div
    b-dropdown(position="is-bottom-left" v-model='dropdownnavMenuOpen')
      a.button.is-primary.is-large.is-outlined(slot="trigger")
        i.mdi.mdi-menu
      b-dropdown-item(has-link): a(@click.prevent='openModal')
        | Shares
      b-dropdown-item(has-link): a(href='/v2/assign_faces/unassigned')
        | Unzuwiesene Gesichter
      b-dropdown-item(has-link): a(href='/upload')
        | Upload
    b-modal(:active.sync="shareModalOpen")
      .card: .card-content
        .panel
          p.panel-heading Shares
          .panel-block(v-for='share in shares')
            a.columns(:href="'/shares/' + share.token" target='_blank' style='width: 100%')
              .column
                | {{ share.name }}
              small.column
                |{{ share.created_at | moment('LL') }}
                |
                span.tag {{share.file_count }} Datei(en)

</template>

<script>
import Api from 'picapp/api';
export default {
  data() {
    return {
      dropdownnavMenuOpen: false,
      shareModalOpen: false,
      shares: [],
    }
  },
  methods: {
    openModal() {
      this.api.getShares().then(r => this.shares = r.data)
      this.shareModalOpen = true
      this.dropdownnavMenuOpen = false
    },
  },
  computed: {
    api() { return new Api() },
  }
}
</script>
