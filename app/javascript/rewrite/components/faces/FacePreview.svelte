<script>
  export let face
</script>

<div class="face-preview" on:click class:selected={face.isSelected}>
  <img src={face.preview} alt={face.person_name} />
  <small title="Similarity / Confidence it's a face at all" class="similarity">
    {Math.round(face.similarity)} / {Math.round(face.confidence)}
  </small>
</div>

<style>
  .similarity {
    font-size: 0.8rem;
    display: block;
    text-align: center;
    color: #999;
  }
</style>
