<script>
  export let file
</script>


<video autoplay poster={file.preview} controls>
  <source src={file.href} type='video/mp4' />
</video>


<style>
  video {
    max-height: 95vh;
    height: auto;
    max-width: 80vw;
  }
</style>
