<template lang="pug">
  div.upload-wrapper
    b-dropdown(position="is-bottom-left" v-model='dropdownOpen')
      a.button.is-primary.is-large.is-outlined(slot="trigger")
        i.mdi.mdi-cloud-upload
        span.internal-progress(v-if='uploadInProgress' :style='{ height: progress + "%"}')
      b-dropdown-item(custom)
        vue-clip(:options="uploaderOptions" :on-queue-complete="onQueueComplete" :on-added-file="onStartUpload" :on-complete='onFileUploaded' :on-total-progress='onTotalProgress')
          template(slot="clip-uploader-action" slot-scope="params")
            .uploader-action(v-bind:class="{'is-dragging': params.dragging}" )
              div(class="dz-message"): h2 Click or Drag and Drop files here upload
          template(slot="clip-uploader-body" slot-scope="props")
            .image-preview-wrapper
              .card.image-preview(v-for="file in props.files")
                .card-image
                  img(v-bind:src="file.dataUrl")
                  progress.progress(v-if='file.status != "success" && file.status != "error"' :value="file.progress" max="100")
                  span.has-text-success.indicator(v-if='file.status == "success"')
                    i.mdi.mdi-checkbox-marked-circle
                  span.has-text-danger.indicator(v-if='file.status == "error"')
                    b-tooltip(:label="JSON.stringify(file.errorMessage)" position="is-bottom" type='is-danger')
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
    onTotalProgress(progress, _totalBytes, _bytesSent) {
      this.progress = progress;
    },
    onQueueComplete() {
      this.uploadInProgress = false
    },
    onFileUploaded(file) {
      if (file.status === 'success') {
        return
      }
      if (file.xhrResponse && file.xhrResponse.statusCode === 422) {
        file.errorMessage = file.errorMessage.errors
      } else if (file.xhrResponse && file.xhrResponse.statusCode >= 400) {
        file.errorMessage = file.errorMessage.errors
      }
    },
    onStartUpload(_file) {
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
  .internal-progress {
    height: 50%;
    width: 4px;
    background-color: #7957d5;
    position: absolute;
    transition: height 0.3s ease-in-out;
    right: 0;
    bottom: 0;
  }
  .upload-wrapper .dropdown-menu {
    width: 500px;
  }
  .image-preview.card {
    max-width: 110px;
    margin-bottom: 20px;
    margin-right: 6px;
    .card-content {
      padding: 0.2rem;
    }
    progress {
      position: absolute;
      bottom: 0
    }
    .indicator {
      position: absolute;
      right: 0;
      .fa {
        font-size: 2rem;
      }
      right: 10px;
      top: 5px;
    }
  }
  .image-preview-wrapper {
    display: flex;
    flex-wrap: wrap;
  }
</style>
