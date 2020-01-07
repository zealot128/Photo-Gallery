<script>
  import { Button, Icon } from "svelte-mui"
  import { getContext } from "svelte"
  const api = getContext("api")

  import ForkedDialog from "rewrite/components/ForkedDialog.svelte"
  import MediaFile from "rewrite/lib/MediaFile"
  import PictureShow from "rewrite/components/PictureShow.svelte"
  import GalleryList from "rewrite/components/GalleryList.svelte"

  let filter = {
    people_ids: [],
    labels: [],
    apertures: [],
    camera_models: [],
    perPage: 25,
  }
  let page = 1
  let hasMore = false

  let photos = []
  let facets = {}
  let meta = {}
  let selected = []
  let isOpen = false
  let currentFile

  const fetchPage = async () => {
    const response = await api.getPhotos(page, filter)
    meta = response.data.meta
    facets = response.data.facets
    if (page > 1) {
      photos = [...photos, ...response.data.data.map(p => new MediaFile(p))]
    } else {
      photos = response.data.data.map(p => new MediaFile(p))
    }
  }
  fetchPage()
  $: hasMore = meta && meta.current_page < meta.total_pages

  const nextPage = () => {
    page++
    fetchPage()
  }

  const reload = async newFilter => {
    page = 1
    fetchPage()
  }

  const openFile = ({ detail }) => {
    currentFile = { ...detail.file }
    isOpen = true
  }
  $: if (!isOpen) {
    currentFile = null
  }

  const deleteFile = ({ detail }) => {
    const index = photos.map(e => e.id).indexOf(detail.id)

    photos = photos.filter(e => e.id !== detail.id)

    if (index >= photos.length) {
      currentFile = photos[photos.length - 1]
    } else {
      currentFile = photos[index]
    }
    api.deletePhoto(detail.id)
  }

  import FilterSidebar from "rewrite/components/filter/FilterSidebar.svelte"
  import SvelteInfiniteScroll from "svelte-infinite-scroll/src/lib/InfiniteScroll.svelte"
  let rightVisible = false
  import { mdiFilterOutline } from "@mdi/js"
</script>

<main>
  <div style="position: absolute; right: 15px; top 15px;">
    <Button on:click={e => (rightVisible = !rightVisible)}>
      <Icon path={mdiFilterOutline} />
    </Button>
  </div>

  <FilterSidebar
    bind:visible={rightVisible}
    {facets}
    on:reload={e => reload(e.detail)}
    bind:filter />
  <ForkedDialog bind:visible={isOpen}>
    {#if isOpen && currentFile}
      <PictureShow {currentFile} on:delete={deleteFile} />
    {/if}
  </ForkedDialog>
  <GalleryList {photos} bind:currentFile on:open={openFile} />

  <SvelteInfiniteScroll
    threshold={100}
    on:loadMore={nextPage}
    {hasMore}
    window={true} />
</main>
