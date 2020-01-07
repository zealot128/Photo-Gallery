<script>
  export let path
  export let width = "24px"
  export let height = width
  export let alt = "Icon"
</script>

<svg style={`width:${width};height: ${height}`} viewBox="0 0 24 24" {alt}>
  <path fill="currentColor" d={path} />
</svg>
