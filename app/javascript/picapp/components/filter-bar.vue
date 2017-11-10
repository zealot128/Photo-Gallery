<template lang="pug">
  .search-container
    b-dropdown(position="is-bottom-left")
      a.button.is-primary.is-medium.is-outlined(slot="trigger")
        i.mdi.mdi-magnify
        i.mdi.mdi-menu-down
      b-dropdown-item(custom paddingless)
        .modal-card(style='min-width: 300px; max-width: 600px')
          section.modal-card-body
            |Filter
</template>

<script>
import SugarDate from 'picapp/sugar-date'

export default {
}
</script>

<style lang='scss'>
.search-container {
  position: fixed;
  right: 15px;
  top: 15px;
  z-index: 1;

}
</style>

