<script>
  export let face
  export let width
  export let height
  import FaceModal from "./FaceModal.svelte"
  import { onDestroy } from "svelte"

  const title = face.person_name
  const href = `/v2/faces/${face.id}`

  const bb = face.bounding_box
  const w = Math.round(bb.width * width)
  const h = Math.round(bb.height * height)
  const t = Math.round(bb.top * height)
  const l = Math.round(bb.left * width)
  const style = `
    left: ${l}px;
    top: ${t}px;
    width: ${w}px;
    height: ${h}px;`

  let editMode = false

  import keybus from "rewrite/components/keybus"
  onDestroy(() => {
    keybus.removeKeyListener("Escape", "face")
    keybus.removeKeyListener("F", "face")
    keybus.removeKeyListener("ArrowRight", "face")
    keybus.removeKeyListener("ArrowLeft", "face")
  })
  keybus.addKeyListener("Escape", "face", 0, event => {
    if (editMode) {
      editMode = false
      event.preventDefault()
      event.stopPropagation()
    }
  })
  keybus.addKeyListener("F", "face", 0, event => {
    if (editMode) {
      editMode = false
    }
  })
  keybus.addKeyListener("ArrowLeft", "face", 0, event => {
    if (editMode) {
      editMode = false
    }
  })
  keybus.addKeyListener("ArrowRight", "face", 0, event => {
    if (editMode) {
      editMode = false
    }
  })
</script>

<div
  class="bb-face"
  {style}
  target="_blank"
  {title}
  on:click={e => (editMode = true)}>
  {#if title}
    <span>{title}</span>
  {:else}
    <span>?</span>
  {/if}
  {#if editMode}
    <FaceModal {face} on:close={e => (editMode = false)} visible={editMode} />
  {/if}
</div>

<style>
  .bb-face {
    border: 2px solid #ddd;
    position: absolute;
    color: white;
    text-align: center;
    cursor: pointer;
  }
</style>
