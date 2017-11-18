<template lang="pug">
  b-dropdown(position="is-bottom-left" v-model='dropdownnavMenuOpen')
    a.button.is-primary.is-large.is-outlined(slot="trigger")
      i.mdi.mdi-menu
    b-dropdown-item(has-link): a(href='/shares')
      | Shares
    b-dropdown-item(has-link): a(href='/v2/assign_faces/unassigned')
      | Unzuwiesene Gesichter
    b-dropdown-item(has-link): a(href='/upload')
      | Upload
</template>

<script>
export default {
  data() {
    return {
      dropdownnavMenuOpen: false,
    }
  }
}
</script>
