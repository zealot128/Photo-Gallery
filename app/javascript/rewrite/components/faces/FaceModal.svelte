<script>
  import { createEventDispatcher } from "svelte"
  import { Button, ButtonGroup } from "svelte-mui"
  import AssignFaces from "./AssignFaces.svelte"
  import EditFace from "./EditFace.svelte"
  const dispatch = createEventDispatcher()

  export let face
  export let visible
  let page = "change"
  if (face.person_name) {
    page = "assign"
  }
  const close = (e) => e.stopPropagation() || dispatch("close")

  let sub
  // Teleport
  import { onMount } from "svelte"
  onMount(() => {
    document.body.appendChild(sub)
  })
  import { mdiClose } from "@mdi/js"
  $: if (!visible) {
    debugger
  }
</script>

{#if visible}
  <div bind:this={sub} class="wrapper">
    <div class="edit-window">
      <div class="header">
        <ButtonGroup color="primary">
          <Button
            on:click={e => (page = 'change')}
            raised
            active={page == 'change'}
            toggle>
            Change
          </Button>
          <Button
            on:click={e => (page = 'assign')}
            raised
            active={page == 'assign'}
            toggle
            disabled={!face.person_name}>
            Mass-Assign
          </Button>
        </ButtonGroup>
        <a class="close" on:click|preventDefault|stopPropagation={close} href="#">
          <svg
            style="width:24px;height:24px"
            viewBox="0 0 24 24"
            alt="Close Icon">
            <path fill="currentColor" d={mdiClose} />
          </svg>
        </a>
      </div>
      {#if page == 'change'}
        <EditFace {face} on:save={e => (page = 'assign')} />
      {:else}
        <AssignFaces {face} />
      {/if}

    </div>
  </div>
{/if}

<style>
  .header {
    display: flex;
    justify-content: space-between;
  }
  .wrapper {
    width: 100vw;
    height: 100vh;
    position: absolute;
    top: 0;
    z-index: 30;
    padding: 30px;
  }
  .close {
    cursor: pointer;
    align-self: end;
  }
  .edit-window {
    display: flex;
    flex-direction: column;
    position: absolute;
    background: #333;
    color: black;
    width: auto;
    padding: 15px;
    box-shadow: 0 0 3px #666;
    border-radius: 5px;
    max-width: 80vh;
    min-width: 350px;
    min-height: 80vh;
    margin: auto;
    position: static;
  }
</style>
