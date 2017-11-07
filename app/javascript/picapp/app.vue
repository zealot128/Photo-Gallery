<template>
  <div id="app">
    <p>{{ message }}</p>
    <i class="mdi mdi-bell"></i>
  </div>
</template>

<script>
export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
