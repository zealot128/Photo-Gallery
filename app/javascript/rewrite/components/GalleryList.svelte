<script>
  export let photos = []
  export let currentFile = {}
  import PicturePreview from "./previews/PicturePreview.svelte"
  import VideoPreview from "./previews/VideoPreview.svelte"

  const moveNext = () => {
    const index = photos.map(e => e.id).indexOf(currentFile.id)
    if (index == -1) {
      currentFile = photos[photos.length - 1]
    } else if (index < photos.length - 1) {
      currentFile = photos[index + 1]
    }
  }
  const movePrev = () => {
    const index = photos.map(e => e.id).indexOf(currentFile.id)
    if (index > 0) {
      currentFile = photos[index - 1]
    }
  }

  import groupBy from "utils/groupBy"
  let groupedPhotos
  $: groupedPhotos = groupBy(photos, p => p.shotAt.toISOString().split("T")[0])

  import { onDestroy } from "svelte"
  import keybus from "rewrite/components/keybus"
  keybus.addKeyListener("ArrowRight", "galleryList", 0, event => moveNext())
  keybus.addKeyListener("ArrowLeft", "galleryList", 0, event => movePrev())
  onDestroy(() => {
    keybus.removeKeyListener("ArrowRight", "galleryList")
    keybus.removeKeyListener("ArrowLeft", "galleryList")
  })

  const formatter = new Intl.DateTimeFormat("de-DE", {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  })
</script>

{#each Object.entries(groupedPhotos) as [group, p] (group)}
  <h4 class="day">{formatter.format(new Date(group))}</h4>
  <div class="media-list">
    {#each p as photo (photo.id)}
      {#if photo.data.type === 'Photo' }
        <PicturePreview
          {photo}
          on:open
          showing={currentFile ? currentFile.id == photo.id : false} />
      {:else}
        <VideoPreview
          video={photo}
          on:open
          showing={currentFile ? currentFile.id == photo.id : false} />
      {/if}
    {/each}
  </div>

{/each}

<style>
  .media-list {
    display: flex;
    flex-wrap: wrap;
  }
</style>
