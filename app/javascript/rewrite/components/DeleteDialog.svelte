<script>
  import { Snackbar, Button } from "svelte-mui"
  import keybus from "rewrite/components/keybus"
  import { onDestroy } from "svelte"
  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()

  export let file

  let showDelete = false

  const confirmDelete = () => {
    showDelete = false
    dispatch("delete", file)
  }

  keybus.addKeyListener("Escape", "delete", 1, event => {
    if (showDelete) {
      event.stopPropagation()
      showDelete = false
    }
  })
  keybus.addKeyListener("D", "delete", 0, event => {
    event.stopPropagation()
    if (showDelete) {
      confirmDelete()
    } else {
      showDelete = true
    }
  })
  onDestroy(() => {
    keybus.removeKeyListener("D", "delete")
  })
</script>

<Snackbar bind:visible={showDelete} timeout="0">
  Really delete?
  <span slot="action">
    <Button color="#ff0" on:click={() => confirmDelete()}>
      Delete (d/Enter)
    </Button>
    <Button color="#ff0" on:click={() => (showDelete = false)}>Cancel</Button>
  </span>
</Snackbar>
