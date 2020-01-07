<script>
  export let video
  export let showing

  import LikeButton from "../LikeButton.svelte"
  import Icon from "../Icon.svelte"
  import { mdiPlayCircle } from "@mdi/js"

  import { createEventDispatcher } from "svelte"
  const dispatch = createEventDispatcher()

  const onClick = () => {
    dispatch("open", { file: video })
  }

  let currentFrame = video.preview
  let mouseIsOver = false
  let currentFrameIndex = 0

  const duration = video.data.exif.durationHuman

  const resetFrame = () => {
    currentFrame = video.preview
    currentFrameIndex = 0
  }
  const frame = () => {
    if (!mouseIsOver) {
      return
    }
    const next_image = video.data.thumbnails[currentFrameIndex]
    if (next_image) {
      currentFrame = next_image
      currentFrameIndex += 1
    } else {
      resetFrame()
    }
    setTimeout(() => frame(), 500)
  }
  const onMouseEnter = () => {
    mouseIsOver = true
    frame()
  }
  const onMouseLeave = e => {
    mouseIsOver = false
    resetFrame()
  }
</script>

<div
  class="gallery-element gallery-element-video"
  class:selected={video.isSelected}
  class:showing={!!showing}
  on:mouseenter={onMouseEnter}
  on:mouseleave={onMouseLeave}>
  <i class="play-icon" on:click={onClick}>
    <Icon path={mdiPlayCircle} width='48px'/>
  </i>
  {#if !video.data.video_processed}
    <span>unprocessed</span>
  {/if}
  <div class="duration">{duration}</div>
  <LikeButton bind:isLiked={video.isLiked} id={video.id} />

  <img class="media-element" src={currentFrame} on:click={onClick} />
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
  .play-icon {
    position: absolute;
    color: #666;
    width: auto;
    transition: color 0.3s ease;
    left: 45px;
    top: 45px;
  }
  .duration {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    color: #666;
    transition: color 0.3s ease;
  }
  .gallery-element:hover .duration {
    transition: color 0.3s ease;
    color: white;
    text-shadow: 0 0 2px #555;
  }
  .gallery-element:hover .play-icon {
    color: white;
    transition: color 0.3s ease;
  }
  .unprocessed {
    text-align: center;
    position: absolute;
    left: 0;
    right: 0;
    font-style: italic;
    color: #444;
  }
  .preload {
    opacity: 0;
    position: absolute;
    z-index: -1;
    width: 1px;
  }
</style>
