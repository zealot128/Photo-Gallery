<script>
  export let facets = []
  export let name
  export let toKey = (obj) => obj
  export let selected

  let show = 5
  let hasMore = false
  import ExpansionPanel from "rewrite/lib/ForkedExpansionPanel"

  $: hasMore = facets.length > show

  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()
  const select = (what) => {
    dispatch("select", toKey(what))
  }
</script>

{#if facets && facets.length > 0}
  <ExpansionPanel {name} group="">
    <div>
      {#each facets.slice(0, show) as label}
        <div class="label" on:click={e => select(label)} class:active={selected.includes(toKey(label))}>
          <slot name="item" item={label}>{label.name} <small>(x{label.count})</small></slot>
        </div>
      {/each}
      {#if hasMore}
        <div class="label">
          <a on:click={e => (show += 5)}>More...</a>
        </div>
      {/if}
      <slot name="footer"></slot>
    </div>
  </ExpansionPanel>
{/if}

<style>
  a {
    cursor: pointer;
  }
  .label {
    font-size: 0.9rem;
    color: #ddd;
    line-height: 1.5;
    cursor: pointer;
    border: 1px solid transparent;
    align-items: center;
    display: flex;
    align-content: center;
    margin-bottom: 5px;
    padding: 3px;
    transition: all 0.1s ease-in;
  }
  .label.active {
    border-color: #448;
    background: #337;
  }
</style>
