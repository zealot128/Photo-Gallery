<script>
  export let currentFile
</script>

<div class="meta-information">
  <span title="Aufnahmedatum">
    <svg viewBox="0 0 24 24">
      <path
        fill="currentColor"
        d="M19,19H5V8H19M16,1V3H8V1H6V3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0
        5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3H18V1M17,12H12V17H17V12Z" />
    </svg>
    {currentFile.data.shot_at_formatted}
  </span>
</div>
{#if currentFile.exif && currentFile.exif.model}
  <div class="meta-information">
    <span title="Kamera">
      <svg viewBox="0 0 24 24">
        <path
          fill="currentColor"
          d="M20,4H16.83L15,2H9L7.17,4H4A2,2 0 0,0 2,6V18A2,2 0 0,0 4,20H20A2,2
          0 0,0 22,18V6A2,2 0 0,0
          20,4M20,18H4V6H8.05L9.88,4H14.12L15.95,6H20V18M12,7A5,5 0 0,0 7,12A5,5
          0 0,0 12,17A5,5 0 0,0 17,12A5,5 0 0,0 12,7M12,15A3,3 0 0,1 9,12A3,3 0
          0,1 12,9A3,3 0 0,1 15,12A3,3 0 0,1 12,15Z" />
      </svg>
      {currentFile.exif.model}
    </span>
  </div>
{/if}
<div class="meta-information">
  {#if currentFile.exif && currentFile.exif.aperture}
    <span title="Aperture">
      <svg viewBox="0 0 24 24">
        <path
          fill="currentColor"
          d="M13.73,15L9.83,21.76C10.53,21.91 11.25,22 12,22C14.4,22 16.6,21.15
          18.32,19.75L14.66,13.4M2.46,15C3.38,17.92 5.61,20.26
          8.45,21.34L12.12,15M8.54,12L4.64,5.25C3,7 2,9.39 2,12C2,12.68
          2.07,13.35 2.2,14H9.69M21.8,10H14.31L14.6,10.5L19.36,18.75C21,16.97
          22,14.6 22,12C22,11.31 21.93,10.64 21.8,10M21.54,9C20.62,6.07
          18.39,3.74 15.55,2.66L11.88,9M9.4,10.5L14.17,2.24C13.47,2.09 12.75,2
          12,2C9.6,2 7.4,2.84 5.68,4.25L9.34,10.6L9.4,10.5Z" />
      </svg>
      {currentFile.exif.aperture}
    </span>
  {/if}
  {#if currentFile.exif && currentFile.exif.exposure_time}
    <span title="Exposure">
      <svg viewBox="0 0 24 24">
        <path
          fill="currentColor"
          d="M4.94,6.35C4.55,5.96 4.55,5.32 4.94,4.93C5.33,4.54 5.96,4.54
          6.35,4.93L13.07,10.31L13.42,10.59C14.2,11.37 14.2,12.64
          13.42,13.42C12.64,14.2 11.37,14.2
          10.59,13.42L10.31,13.07L4.94,6.35M12,20A8,8 0 0,0 20,12C20,9.79
          19.1,7.79 17.66,6.34L19.07,4.93C20.88,6.74 22,9.24 22,12A10,10 0 0,1
          12,22A10,10 0 0,1 2,12H4A8,8 0 0,0 12,20M12,1A2,2 0 0,1 14,3A2,2 0 0,1
          12,5A2,2 0 0,1 10,3A2,2 0 0,1 12,1Z" />
      </svg>
      {currentFile.exif.exposure_time}
    </span>
  {/if}
  {#if currentFile.exif && currentFile.exif.focal_length}
    <span title="Focal length">
      <svg viewBox="0 0 24 24">
        <path
          fill="currentColor"
          d="M20 4H16.8L15 2H9L7.2 4H4C2.9 4 2 4.9 2 6V18C2 19.1 2.9 20 4
          20H20C21.1 20 22 19.1 22 18V6C22 4.9 21.1 4 20 4M9.9 4H14.1L15.9
          6H20V18H4V6H8.1M15 11H9V8.5L5.5 12L9 15.5V13H15V15.5L18.5 12L15
          8.5V11Z" />
      </svg>
      {currentFile.exif.focal_length}
    </span>
  {/if}
</div>
{#if currentFile.data.labels.length > 0}
  <div class="meta-information tags">
    {#each currentFile.data.labels as label}
      <span class="label">{label}</span>
    {/each}
  </div>
{/if}

<style>
  .tags {
    display: flex;
    flex-wrap: wrap;
    max-width: 250px;
  }
  .label {
    display: inline-block;
    border: 1px solid;
    padding: 0 3px;
    border-radius: 3px;
    margin-bottom: 1px;
  }
  .meta-information {
    font-size: 0.8rem;
    color: #aaa;
    line-height: 1.5;
    margin: 10px 0;
  }
  .meta-information svg {
    width: 0.8rem;
    height: 0.8rem;
  }
  .meta-information span {
    display: inline-block;
    margin-right: 5px;
  }
</style>
