<script>
  export let face

  import { Textfield } from "svelte-mui"
  import FacePreview from "./FacePreview.svelte"

  // boilerpolate
  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()

  import { getContext } from "svelte"
  const api = getContext("api")

  let personName = face.person_name || ""
  let similarFaces = []
  let existingPeople = []

  let automatchingSuggestions = []

  const getFaceInfo = async () => {
    const response = await api.getSimilarImages(face, 50, 80)
    similarFaces = response.filter(e => e.person_id)

    const suggestions = {}
    similarFaces.forEach(face => {
      if (!suggestions[face.person_id]) {
        suggestions[face.person_id] = {
          count: 1,
          preview: face.preview,
          name: face.person_name,
        }
      } else {
        suggestions[face.person_id].count += 1
      }
    })
    automatchingSuggestions = Object.values(suggestions).sort(
      (a, b) => b.count - a.count
    )
  }
  const getPeople = async () => {
    existingPeople = await api.getPeople()
  }
  const save = async () => {
    const response = await api.setFaces(personName, [face.id], [])
    face.person_name = response.person.name
    face.person_id = response.person.id
    dispatch("save", face)
  }
  getFaceInfo()
  getPeople()
</script>

<div style="display: flex; align-items: center;">
  <form on:submit|preventDefault={save}>
    <Textfield
      autocomplete="off"
      placeholder="Person Name"
      required
      bind:value={personName} />
  </form>
  <a
    class="button"
    class:disabled={!personName || personName.length < 2}
    on:click={save}>
    Create
  </a>
</div>
{#if automatchingSuggestions.length > 0}
  <div>Suggestions:</div>
  {#each automatchingSuggestions as suggestion}
    <div class="face-preview" on:click={e => (personName = suggestion.name)}>
      <img src={suggestion.preview} />
    </div>
  {/each}
{/if}
