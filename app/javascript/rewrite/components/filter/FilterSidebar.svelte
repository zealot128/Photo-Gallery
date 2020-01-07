<script>
  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()
  import { getContext } from "svelte"
  const api = getContext("api")

  export let visible = false
  export let filter = []

  import { Sidepanel, Menuitem, Button, Checkbox } from "svelte-mui"
  import FacetList from './FacetList.svelte'
  import DateFilter from './DateFilter.svelte'
  import watcher from "utils/watcher"

  $: localFilter = filter

  let facets = {}

  const fetchFacets = async () => {
    facets = await api.facets(localFilter)
  }
  $: if (visible && !facets.labels) fetchFacets()

  const setFacets = (key, selected) => {
    if (!filter[key]) {
      filter[key] = [selected]
    } else {
      if (filter[key].includes(selected)) {
        filter[key] = filter[key].filter(e => e !== selected)
      } else {
        filter[key] = [...filter[key], selected]
      }
    }
    filter = filter
  }
</script>

<Sidepanel right bind:visible>
  <ul>
    <Menuitem style='margin: 15px 0;'>
      <Button raised on:click={e => dispatch('reload', filter)}>Refresh</Button>
    </Menuitem>
    <DateFilter bind:from={filter.from} bind:to={filter.to}/>
    {#if facets && facets.people}
      <FacetList facets={facets.people} name="People" toKey={obj => obj.person.id} on:select={e => setFacets("people_ids", e.detail) } selected={filter.people_ids}>
        <span class='person-item' slot="item" let:item={item}>
          <img src={item.person.preview}>
          {item.person.name}

          <small>({item.count})</small>
        </span>

        <span slot="footer">
          <Checkbox bind:checked={filter.match_any_face} disabled={!filter.people_ids || filter.people_ids.length < 2}>OR-Search</Checkbox>
        </span>
      </FacetList>
    {/if}
    {#if facets && facets.labels}
      <FacetList facets={facets.labels} name="Labels" on:select={e => setFacets("labels", e.detail) } selected={filter.labels} toKey={e => e.name}/>
    {/if}
    {#if facets && facets.cameras}
      <FacetList facets={facets.cameras} name="Camera" on:select={e => setFacets("camera_models", e.detail) } selected={filter.camera_models} toKey={e => e.name}/>
    {/if}
    {#if facets && facets.cameras}
      <FacetList facets={facets.apertures} name="Apertures" on:select={e => setFacets("apertures", e.detail) } selected={filter.apertures} toKey={e => e.name}/>
    {/if}
  </ul>
</Sidepanel>

<style>
  .person-item small {
    margin-left: 5px;
  }
  .person-item {
    display: flex;
    align-items: center;
  }
  .person-item img{
    margin-right: 5px;
    height: 35px;
    border: 1px solid #666;
    border-radius: 3px;
  }
  ul {
    margin: 0;
    padding: 8px 0;
    width: 100%;
  }
</style>
