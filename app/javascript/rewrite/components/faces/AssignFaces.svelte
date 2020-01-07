<script>
  export let face
  import { getContext } from "svelte"
  import FacePreview from "./FacePreview.svelte"
  import { Textfield, Button } from "svelte-mui"
  import {
    mdiCheckBoxMultipleOutline,
    mdiCheckboxMultipleBlankOutline,
  } from "@mdi/js"
  import Icon from "rewrite/components/Icon"

  const api = getContext("api")
  let max = 100
  let confidence = 0
  let similarity = 80

  let similarFaces = []
  const getFaceInfo = async () => {
    const response = await api.getSimilarImages(face, max, similarity)
    similarFaces = response.filter(e => !e.person_id)
  }
  const merge = async () => {
    const ids = similarFaces.filter(e => e.isSelected).map(e => e.id)

    await api.setFaces(face.person_name, ids)

    getFaceInfo()
  }
  const selectAll = () => {
    similarFaces = similarFaces.map(e => ({ ...e, isSelected: true }))
  }
  const selectNone = () => {
    similarFaces = similarFaces.map(e => ({ ...e, isSelected: false }))
  }
  getFaceInfo()
</script>

<div style="display: flex">
  <Textfield autocomplete="off" label="Max. Photos" required bind:value={max} />
  <Textfield
    autocomplete="off"
    label="Confidence"
    required
    bind:value={confidence} />
  <Textfield
    autocomplete="off"
    label="Similarity"
    required
    bind:value={similarity} />
</div>
<Button raised variant="primary" on:click={getFaceInfo}>Refresh</Button>
<div class="select-actions">
  <Button
    on:click={merge}
    disabled={!similarFaces.some(f => f.isSelected)}
    variant="primary"
    raised>
    Assign to {face.person_name}
  </Button>
  <Button on:click={selectAll} variant="primary">
    <Icon path={mdiCheckBoxMultipleOutline} />
  </Button>
  <Button on:click={selectNone} variant="primary">
    <Icon path={mdiCheckboxMultipleBlankOutline} />
  </Button>
</div>
<div class="faces">
  {#each similarFaces as face (face.id)}
    <FacePreview {face} on:click={e => (face.isSelected = !face.isSelected)} />
  {/each}
</div>

<style>
  .faces {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    grid-gap: 0.5rem;
    margin-top: 30px;
  }
  .select-actions {
    display: flex;
    margin-top: 15px;
  }
</style>
