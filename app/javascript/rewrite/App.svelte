<script>
  // API
  import { setContext } from "svelte"
  export let csrfToken
  import Api from "rewrite/lib/api.js"
  const api = new Api(csrfToken)
  setContext("api", api)
  setContext("csrfToken", csrfToken)

  import Router from "svelte-router-spa/src/components/router.svelte"
  import { Sidepanel, Menuitem, Button, Icon } from "svelte-mui"
  import { mdiMenu } from "@mdi/js"
  import Gallery from "./routes/Gallery.svelte"
  import Upload from "./routes/Upload.svelte"

  const routes = [
    {
      name: "/v4",
      component: Gallery,
    },
    {
      name: "/v4/upload",
      component: Upload,
    },
     // Example of a custom 404 route
    {
      name: '404',
      path: '404',
      component: Gallery,
    }
  ]
  let visible = false
</script>

<Sidepanel left bind:visible>
  <Menuitem href="/v4/" on:click={e => visible = false }>Gallery</Menuitem>
  <Menuitem href="/v4/upload" on:click={e => visible = false }>Upload</Menuitem>
</Sidepanel>

<div style="position: absolute; left: 15px; top 15px;">
  <Button on:click={e => (visible = !visible)}>
    <Icon path={mdiMenu} />
  </Button>
</div>
<Router {routes} />

<style>
</style>
