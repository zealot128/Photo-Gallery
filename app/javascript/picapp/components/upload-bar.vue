<template lang="pug">
  div
    b-dropdown(position="is-bottom-left" v-model='dropdownOpen')
      a.button.is-primary.is-large.is-outlined(slot="trigger")
        i.mdi.mdi-cloud-upload
      b-dropdown-item(custom)
        vue-clip(:options="uploaderOptions" :on-added-file="startUpload" :on-complete='fileUploaded' :on-total-progress='totalProgress')
          template(slot="clip-uploader-action" slot-scope="params")
            .uploader-action(v-bind:class="{'is-dragging': params.dragging}" )
              div(class="dz-message"): h2 Click or Drag and Drop files here upload
          template(slot="clip-uploader-body" slot-scope="props")
            .tile: .card.image-preview(v-for="file in props.files")
              .card-image
                img(v-bind:src="file.dataUrl")
                progress.progress(v-if='file.status != "success" && file.status != "error"' :value="file.progress" max="100")
                span.has-text-success.indicator(v-if='file.status == "success"')
                  i.mdi.mdi-checkbox-marked-circle
                span.has-text-danger.indicator(v-if='file.status == "error"')
                  b-tooltip(:label="file.errorMessage" position="is-bottom")
                    i.mdi.mdi-alert-circle

              .card-content
                small {{ file.name }}


</template>

<script>
export default {
  data() {
    return {
      dropdownOpen: false,
      uploadInProgress: false,
      progress: 0
    }
  },
  methods: {
    totalProgress(progress, _totalBytes, _bytesSent) {
      this.progress = progress;
    },
    fileUploaded(file) {
      if (file.status === 'success') {
      } else if (file.xhrResponse && file.xhrResponse.statusCode === 422) {
        file.errorMessage = file.errorMessage.errors
      } else if (file.xhrResponse && file.xhrResponse.statusCode >= 400) {
        file.errorMessage = file.errorMessage.errors
      }
    },
    startUpload(_file) {
      this.progress = 0
      this.uploadInProgress = true
    },
  },
  computed: {
    uploaderOptions() {
      return {
        parallelUploads: 2,
        url: '/photos/upload',
        paramName: 'file',
        headers: {
          'X-CSRF-Token': this.$store.state.csrfToken
        }
      }
    }
  }
}
</script>

<style lang='scss'>
  .uploader-action {
    min-width: 300px;
    padding: 50px;
    border: 3px dashed transparent;
    &.is-dragging {
      border-color: #aaa;
      background: #f2f2f2;
    }
  }
  .image-preview {
    max-width: 120px !important;
    progress {
      position: absolute;
      bottom: 0
    }
    .indicator {
      position: absolute;
      right: 0;
      font-size: 2rem;
    }
  }
</style>
