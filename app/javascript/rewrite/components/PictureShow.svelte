<script>
  export let currentFile
  import PictureMeta from "./PictureMeta.svelte"
  import DeleteDialog from "./DeleteDialog.svelte"
  import BoundingBoxFace from "./faces/BoundingBoxFace.svelte"
  import VideoPlayer from './VideoPlayer.svelte'
  import { mdiFaceOutline } from "@mdi/js"

  let lastFile = currentFile.id
  let showFaces = false
  let faceMode = false
  let hasFaces = false
  let width
  let height

  import keybus from "rewrite/components/keybus"
  import { onDestroy } from "svelte"

  keybus.addKeyListener("F", "picture_f", 0, event => {
    if (hasFaces) {
      event.stopPropagation()
      faceMode = !faceMode
    }
  })
  onDestroy(() => {
    keybus.removeKeyListener("F", "picture_f")
  })

  $: {
    if (currentFile.id !== lastFile) {
      showFaces = false
      faceMode = false
      lastFile = currentFile.id
    }
  }

  $: hasFaces = currentFile.data.faces && currentFile.data.faces.length > 0
  $: faceMode = showFaces && hasFaces
</script>

<DeleteDialog file={currentFile} on:delete />
<div class="meta">
  <a class="button" href={currentFile.data.download_url} target="_blank">
    Download
    <small>{currentFile.data.file_size_formatted}</small>
  </a>
  <PictureMeta {currentFile} />
  {#if hasFaces}
    <a
      class="button"
      class:active={faceMode}
      on:click={e => (faceMode = !faceMode)}>
      <svg style="width:0.9rem;height:0.9rem;" viewBox="0 0 24 24">
        <path fill="currentColor" d={mdiFaceOutline} />
      </svg>
      {currentFile.data.faces.length}
    </a>
  {/if}
</div>

<div bind:clientWidth={width} bind:clientHeight={height}>
  {#if currentFile.data.type == 'Video' }
    <VideoPlayer file={currentFile} class="main-image"/>
  {:else}
    <img src={currentFile.href} class="main-image" alt="Main Image" />
  {/if}
  {#if faceMode}
    {#each currentFile.data.faces as face}
      <BoundingBoxFace {face} {width} {height} />
    {/each}
  {/if}
</div>

<style>
  .meta {
    position: absolute;
    top: 5px;
    left: 5px;
    background: rgba(0, 0, 0, 0.5);
    padding: 15px;
  }
  img {
    max-height: 95vh;
    height: auto;
    max-width: 80vw;
  }
</style>
