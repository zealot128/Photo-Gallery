<script>
  import { tick, onMount, onDestroy, createEventDispatcher } from "svelte"
  import { fade, scale } from "svelte/transition"
  import { quintOut } from "svelte/easing"
  import { current_component } from "svelte/internal"
  import { getEventsAction } from "svelte-mui/src/lib/events"
  import enableScroll from "svelte-mui/src/lib/enableScroll"

  const dispatch = createEventDispatcher()
  const events = getEventsAction(current_component)

  export { visible, closeByEsc, beforeClose }

  let visible = false
  let closeByEsc = true
  let beforeClose = () => true

  let mouseDownOutside = false

  let attrs = {}

  $: {
    /* eslint-disable no-unused-vars */
    const { visible, closeByEsc, beforeClose, ...other } = $$props

    attrs = other
  }

  let mounted = false
  let elm

  $: if (visible) {
    mounted && enableScroll(false)
    onVisible()
  } else {
    mouseDownOutside = false
    mounted && enableScroll(true)
  }

  onMount(async () => {
    await tick()
    mounted = true
  })

  const close = params => {
    if (beforeClose()) {
      dispatch("close", params)
      visible = false
      history.back()
    }
  }

  import keybus from "rewrite/components/keybus"
  keybus.addKeyListener("Escape", "gallery", 0, event => {
    if (closeByEsc) {
      event.stopPropagation()
      close("Escape")
    }
  })
  function onKey(e) {
    keybus.onKey(e)
  }
  onDestroy(() => {
    keybus.removeKeyListener("Escape", "gallery")
    mounted && enableScroll(true)
  })

  async function onVisible() {
    history.pushState({}, "", window.location)

    if (!elm) return

    await tick()
    let inputs = elm.querySelectorAll('input:not([type="hidden"])')
    let length = inputs.length
    let i = 0

    for (; i < length; i++) {
      if (inputs[i].getAttribute("autofocus")) {
        break
      }
    }
    i < length
      ? inputs[i].focus()
      : length > 0
      ? inputs[0].focus()
      : elm.focus()
    dispatch("open")
  }

  function onPopstate() {
    visible = false
  }
</script>

<svelte:window on:keydown={onKey} on:popstate={onPopstate} />

{#if visible}
  <div transition:fade={{ duration: 180 }} class="overlay">

    <button
      class="dialog__close"
      on:click={e => close('clickOutside')}
      title="Close">
      <svg style="width:24px;height:24px" viewBox="0 0 24 24" alt="Close Icon">
        <path
          fill="currentColor"
          d="M19,6.41L17.59,5L12,10.59L6.41,5L5,6.41L10.59,12L5,17.59L6.41,19L12,13.41L17.59,19L19,17.59L13.41,12L19,6.41Z" />
      </svg>
    </button>
    <div
      class="dialog"
      tabindex="-1"
      in:scale={{ duration: 180, opacity: 0.5, start: 0.75, easing: quintOut }}
      bind:this={elm}
      use:events>
      <slot />
    </div>
  </div>
{/if}

<style>
  .overlay {
    background-color: rgba(0, 0, 0, 0.5);
    position: fixed;
    left: 0;
    top: 0;
    right: 0;
    bottom: 0;
    z-index: 30;

    display: flex;
    justify-content: center;
    align-items: center;
  }

  .dialog {
    font-size: 1rem;
    background: #eee;
    /* postcss-custom-properties: ignore next */
    background: var(--bg-panel, #eee);
    border-radius: 4px;
    cursor: auto;
    box-shadow: 0 11px 15px -7px rgba(0, 0, 0, 0.2),
      0 24px 38px 3px rgba(0, 0, 0, 0.14), 0 9px 46px 8px rgba(0, 0, 0, 0.12);
    z-index: 40;
  }
  .dialog:focus {
    outline: none;
  }
  .dialog::-moz-focus-inner {
    border: 0;
  }
  .dialog:-moz-focusring {
    outline: none;
  }
  div :global(.actions) {
    min-height: 48px;
    padding: 8px;
    display: flex;
    align-items: center;
  }
  div :global(.center) {
    justify-content: center;
  }
  div :global(.left) {
    justify-content: flex-start;
  }
  div :global(.right) {
    justify-content: flex-end;
  }
  .dialog__close {
    position: absolute;
    top: 20px;
    right: 20px;
    background: transparent;
    color: #ddd;
    border: none;
    font-size: 1.2rem;
    cursor: pointer;
  }
  .dialog__close:hover {
    color: white;
  }
</style>
