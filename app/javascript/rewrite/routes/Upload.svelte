<script>
  import { getContext } from "svelte"
  const csrfToken = getContext("csrfToken")

  import Dropzone from "svelte-dropzone"
  import { Icon } from 'svelte-mui'
  import { mdiAlertCircle, mdiCheckboxMarkedCircle } from "@mdi/js"

  let files = []
  let dropdownOpen = false
  let uploadInProgress = false
  let progress = 0

  const options = {
    clicable: true,
    maxFilesize: 200 * 1024 * 1024,
    parallelUploads: 2,
    url: "/photos/upload",
    paramName: "file",
    headers: {
      "X-CSRF-Token": csrfToken,
    },
    acceptedFiles: "image/*,video/*",
  }
  const updateFile = (uuid, update) => {
    files = files.map(f => {
      if (uuid === f.uuid) {
        return { ...f, ...update }
      } else {
        return f
      }
    })
  }
  const dropzoneEvents = {
    addedfile(file) {
      progress = 0
      uploadInProgress = true
      files = [...files, { upload: file.upload, uuid: file.upload.uuid, filename: file.upload.filename, status: file.status }]
    },
    thumbnail(file, dataURL) {
      updateFile(file.upload.uuid, { dataURL })
    },
    uploadprogress(file) {
      updateFile(file.upload.uuid, { upload: file.upload })
    },
    complete(file) {
      updateFile(file.upload.uuid, { status: file.status })
      if (file.status === "success") {
        return
      }
      let errorMessage
      if (file.xhr.response) {
        errorMessage = Object.entries(JSON.parse(file.xhr.response).errors).map(([k, v]) => `${k}: ${v[0]}`)
      } else if (file.xhr) {
        console.error(file.xhr.response)
      }
      updateFile(file.upload.uuid, { errorMessage })
    },
    totaluploadprogress(prog, _totalBytes, _bytesSent) {
      progress = prog
    },
    queuecomplete() {
      uploadInProgress = false
    },
  }
</script>

<div class="container">
  <br />
  <br />
  <h4>Upload files</h4>

  <Dropzone
    dropzoneClass="dropzone"
    hooveringClass="hoovering"
    {dropzoneEvents}
    {options}>
    {#if files.length == 0 }
      <p>Drop files here to upload</p>
    {/if}
    <div class="image-preview-wrapper">
      {#each files as file (file.upload.uuid)}
        <div class="card image-preview">
          <div class="card-image">
            <img src={file.dataURL} />
            {#if file.status != 'success' && file.status != 'error'}
              <progress
                class="progress"
                value={file.upload.progress || 0}
                max="100" />
            {/if}
            {#if file.status == 'success'}
              <span class="has-text-success indicator">
                <Icon path={mdiCheckboxMarkedCircle} />
              </span>
            {/if}
            {#if file.status == 'error'}
              <span
                class="has-text-danger indicator"
                title={JSON.stringify(file.errorMessage)}>
                <Icon path={mdiAlertCircle} />
              </span>
            {/if}
          </div>
          <div class="card-content filename">
            <small>{file.filename}</small>
          </div>
        </div>
      {/each}
    </div>
  </Dropzone>

</div>

<style type='scss'>
  .container {
    margin: 30px;
  }
  :global(.dropzone) {
    width: 100%;
    min-height: 500px;
    border: 1px solid #999;
    color: #333;
  }
  :global(.dropzone.hoovering) {
    border-style: dashed;
    border-color: #555599;
  }

  .image-preview.card .card-content {
    padding: 0.2rem;
  }
  progress {
    position: absolute;
    bottom: 0
  }
  .indicator {
    position: absolute;
    right: 10px;
    top: 5px;
  }
  .image-preview-wrapper {
    display: flex;
    flex-wrap: wrap;
  }
  .card {
    position: relative;
    border: 1px solid #aaa;
    border-radius: 5px;
    max-width: 150px;
    min-height: 120px;
    margin-bottom: 20px;
    margin-right: 6px;
  }
  .text-danger {
    color: #bd3333;
  }
  img {
    margin: auto;
    display: block;
  }
  .filename {
    overflow: hidden;
    text-overflow: ellipsis;
  }
</style>
