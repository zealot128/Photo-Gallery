<script>
  export let photo
  export let showing

  import LikeButton from "../LikeButton.svelte"

  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()

  const onClick = () => {
    // e => (photo.isSelected = !photo.isSelected)

    dispatch("open", { file: photo })
  }
</script>

<div
  class="gallery-element"
  class:selected={photo.isSelected}
  class:showing={!!showing}>
  <LikeButton bind:isLiked={photo.isLiked} id={photo.id} />

  <img class="media-element" src={photo.preview} on:click={onClick} />
</div>

<style>
  .media-element {
    height: 144px;
    object-fit: cover;
  }
  .gallery-element {
    height: 150px;
    position: relative;
    border: 3px solid #222;
    transition: all 0.15s ease-in;
  }
  .gallery-element:hover {
    transform: scale(1.3);
    z-index: 2;
  }
  .gallery-element.selected {
    border-color: #f09739;
  }
  .showing img {
    filter: brightness(1.3) contrast(1.5);
  }
</style>
